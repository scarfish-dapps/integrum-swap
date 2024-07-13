// Allow `cargo stylus export-abi` to generate a main function.
#![cfg_attr(not(feature = "export-abi"), no_main)]
extern crate alloc;

/// Use an efficient WASM allocator.
#[global_allocator]
static ALLOC: mini_alloc::MiniAlloc = mini_alloc::MiniAlloc::INIT;

/// Import items from the SDK. The prelude contains common traits and macros.
use stylus_sdk::{alloy_primitives::U256, alloy_primitives::I256, alloy_primitives::Address, prelude::*};

use stylus_sdk::msg;

// Define some persistent storage using the Solidity ABI.
// `OrderMatcher` will be the entrypoint.
sol_storage! {
    #[entrypoint]
    pub struct OrderMatcher {
        mapping(uint256 => address) orders_user;
        mapping(uint256 => uint256) orders_eid;
        mapping(uint256 => uint256) orders_type;
        mapping(uint256 => address) orders_token0;
        mapping(uint256 => address) orders_token1;
        mapping(uint256 => uint256) orders_amount;
        mapping(uint256 => uint256) orders_filled_amount;
        mapping(uint256 => uint256) orders_price;
        mapping(uint256 => bool) orders_is_filled;
        mapping(uint256 => bool) orders_is_canceled;

        uint256 orders_length;
    }
}

/// Declare that `OrderMatcher` is a contract with the following external methods.
#[external]
impl OrderMatcher {

    pub fn place_limit_order(&mut self, user: Address, eid: U256, order_type: U256, token0: Address, token1: Address, mut amount: U256, price: U256) 
    -> (U256, Address, U256, Address, I256, I256, I256, I256) {
        let orders_length = self.orders_length.get();
        let order_id = orders_length;

        // let user = msg::sender();
        self.orders_user.setter(order_id).set(user);
        self.orders_eid.setter(order_id).set(eid);
        self.orders_type.setter(order_id).set(order_type);
        self.orders_token0.setter(order_id).set(token0);
        self.orders_token1.setter(order_id).set(token1);        
        self.orders_amount.setter(order_id).set(amount);
        self.orders_filled_amount.setter(order_id).set(U256::from(0));
        self.orders_price.setter(order_id).set(price);
        self.orders_is_filled.setter(order_id).set(false);
        self.orders_is_canceled.setter(order_id).set(false);

        self.orders_length.set(orders_length + U256::from(1));

        let mut other_user = Address::default();
        let mut other_eid = U256::from(0);
        let mut amount_token0_delta_user = I256::try_from(0).unwrap();
        let mut amount_token1_delta_user = I256::try_from(0).unwrap();
        let mut amount_token0_delta_other_user = I256::try_from(0).unwrap();
        let mut amount_token1_delta_other_user = I256::try_from(0).unwrap();

        let mut i = U256::from(0);
        while i < orders_length {
            if self.orders_is_filled.get(i) || self.orders_is_canceled.get(i) {
                i += U256::from(1);
                continue;
            }

            if self.orders_token0.get(i) == token0 && self.orders_token1.get(i) == token1 && self.orders_price.get(i) == price {
                if (order_type == U256::from(0) && self.orders_type.get(i) == U256::from(1)) || (order_type == U256::from(1) && self.orders_type.get(i) == U256::from(0)) {
                    // Match orders
                    let matched_amount = self.orders_amount.get(i).min(amount);

                    let new_filled_amount = self.orders_filled_amount.get(i) + matched_amount;
                    self.orders_filled_amount.setter(i).set(new_filled_amount);

                    amount -= matched_amount;

                    if self.orders_amount.get(i) == new_filled_amount {
                        self.orders_is_filled.setter(i).set(true);
                    }

                    other_user = self.orders_user.get(i);
                    other_eid = self.orders_eid.get(i);
                    amount_token0_delta_user = I256::try_from(matched_amount).unwrap();
                    amount_token1_delta_user = I256::try_from(matched_amount * price).unwrap();
                    amount_token0_delta_other_user = I256::try_from(matched_amount).unwrap();
                    amount_token1_delta_other_user = I256::try_from(matched_amount * price).unwrap();

                    break;
                }
            }
            i += U256::from(1);
        }

        // Update current order's filled amount
        let new_filled_amount = self.orders_amount.get(order_id) - amount;
        self.orders_filled_amount.setter(order_id).set(new_filled_amount);

        if amount == U256::from(0) {
            self.orders_is_filled.setter(order_id).set(true);
        } else {
            self.orders_is_filled.setter(order_id).set(false);
        }

        (orders_length, user, other_eid, other_user, amount_token0_delta_user, amount_token1_delta_user, amount_token0_delta_other_user, amount_token1_delta_other_user)
    }

    pub fn retrieve_limit_order(&self, index: U256) -> (U256, Address, U256, U256, Address, Address, U256, U256, U256, bool, bool) {
        (
            index,
            self.orders_user.get(index),
            self.orders_eid.get(index),
            self.orders_type.get(index),
            self.orders_token0.get(index),
            self.orders_token1.get(index),
            self.orders_amount.get(index),
            self.orders_filled_amount.get(index),
            self.orders_price.get(index),
            self.orders_is_filled.get(index),
            self.orders_is_canceled.get(index)
        )
    }
        
    pub fn cancel_limit_order(&mut self, idx: U256) {
        if msg::sender() == self.orders_user.get(idx) {
            self.orders_is_canceled.setter(idx).set(true);
        }
    }

    pub fn cancel_all_limit_orders(&mut self) {
        let user = msg::sender();
        let mut i = U256::from(0);
        while i < self.orders_length.get() {
            if self.orders_user.get(i) == user {
                self.orders_is_canceled.setter(i).set(true);
            }
            i += U256::from(1);
        }
    }

    pub fn place_market_order(&mut self, order_type: U256, token0: Address, token1: Address, mut amount: U256) 
    -> (Address, Address, I256, I256, I256, I256) {
        let user = msg::sender();
        let mut other_user = Address::default();
        let mut amount_token0_delta_user = I256::try_from(0).unwrap();
        let mut amount_token1_delta_user = I256::try_from(0).unwrap();
        let mut amount_token0_delta_other_user = I256::try_from(0).unwrap();
        let mut amount_token1_delta_other_user = I256::try_from(0).unwrap();

        let mut i = U256::from(0);
        while i < self.orders_length.get() {
            if self.orders_is_filled.get(i) || self.orders_is_canceled.get(i) {
                i += U256::from(1);
                continue;
            }

            if self.orders_token0.get(i) == token0 && self.orders_token1.get(i) == token1 {
                if (order_type == U256::from(0) && self.orders_type.get(i) == U256::from(1)) || (order_type == U256::from(1) && self.orders_type.get(i) == U256::from(0)) {
                    // Match orders
                    let matched_amount = self.orders_amount.get(i).min(amount);
                    let matched_price = self.orders_price.get(i);

                    let new_filled_amount = self.orders_filled_amount.get(i) + matched_amount;
                    self.orders_filled_amount.setter(i).set(new_filled_amount);
                    amount -= matched_amount;

                    if self.orders_amount.get(i) == new_filled_amount {
                        self.orders_is_filled.setter(i).set(true);
                    }

                    other_user = self.orders_user.get(i);
                    amount_token0_delta_user = I256::try_from(matched_amount).unwrap();
                    amount_token1_delta_user = I256::try_from(matched_amount * matched_price).unwrap();
                    amount_token0_delta_other_user = I256::try_from(matched_amount).unwrap();
                    amount_token1_delta_other_user = I256::try_from(matched_amount * matched_price).unwrap();

                    break;
                }
            }
            i += U256::from(1);
        }

        (user, other_user, amount_token0_delta_user, amount_token1_delta_user, amount_token0_delta_other_user, amount_token1_delta_other_user)
    }
}
