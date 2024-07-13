// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import {IOrderMatcher} from "./IOrderMatcher.sol";
import {OApp, Origin, MessagingFee } from "lib/LayerZero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/OApp.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./MainContract.sol";

/// Proxies calls to the OrderMatcher contract via LayerZero
contract OrderPlacerProxy is OApp {
    uint32 public eidArbitrumSepolia = 40231;
    uint32 public eid;

    MainContract public mainContract;
    address public hookContract;
    constructor(address _endpoint, address _mainContract, address _hookContract, uint32 _eid, address _owner) OApp(_endpoint, _owner) Ownable(_owner){
        mainContract = MainContract(_mainContract);
        hookContract = _hookContract;
        eid = _eid;
    }
    

    // Some arbitrary data you want to deliver to the destination chain!
    string public data;
    
    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price, address sender, bytes memory _options) external payable {
            
        // Encode order details
        // the proxy always sends to the arbitrum EID so I can use that
        bytes memory _payload = abi.encode(sender, orderType, "LIMIT_ORDER", token0, token1, amount, price);
        _lzSend(
            eidArbitrumSepolia,
            _payload,
            _options,
            // Fee in native gas and ZRO token.
            MessagingFee(msg.value, 0),
            // Refund address in case of failed source message.
            payable(sender) 
        );
    }


    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address,  // Executor address as specified by the OApp.
        bytes calldata  // Any extra data or options to trigger on receipt.
    ) internal override {
        // Decode the payload to get the message
        // data = abi.decode(payload, (string));
        // Extract the sender's EID from the origin
        uint32 senderEid = _origin.srcEid;
        bytes32 sender = _origin.sender;
        (   address token0,
            address token1,
            int256 amountToken0DeltaUser,
            int256 amountToken1DeltaUser
        ) = abi.decode(payload, (address, address, int256, int256));

        // debit tokens to         
        // mineContract.debit()

        // mainContract.credit()



        

        // Emit the event with the decoded message and sender's EID
        // emit MessageReceived(data, senderEid, sender);
    }

    function retrieveLimitOrder(uint256 index, uint256 sender) external view {

    }

    function cancelLimitOrder(uint256 orderId, uint256 sender) external {

    }

    function cancelAllLimitOrders(uint256 sender) external {
    
    }

    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 sender) external {
    }
}
