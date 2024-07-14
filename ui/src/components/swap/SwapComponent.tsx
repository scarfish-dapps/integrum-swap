import React, { useState, ChangeEvent } from 'react';
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import S from './index.module.css';
import DropdownWithSearch from "../DropdownWithSearch.tsx/DropdownWithSearch";
import { Token } from "../../client/tokens";
import { CONFIRMED, ERC20_TOKENS, OrderType } from "../../utils";
import SwapTabs from "../swapTabs/SwapTabs";
import { GET_CONTRACT } from "../../ContractUtils";
import { setLoading } from "../../store/spiner/spinerSlice";
import { parseUnits } from "ethers";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";
import ModalComponent from "../modal/Modal";

const SwapComponent: React.FC = () => {
	const { walletProvider } = useWeb3ModalProvider();
	const dispatch = useAppDispatch();
	const [showModal, setShowModal] = useState(false);
	const [txHash, setTxhash] = useState('');
	
	const balance = useAppSelector((state) => state.user.balance);
	const [selectedToken1, setSelectedToken1] = useState<Token>(ERC20_TOKENS[0]);
	const [value1, setValue1] = useState<number>(0.0);
	
	const [selectedToken2, setSelectedToken2] = useState<Token>(ERC20_TOKENS[1]);
	const [value2, setValue2] = useState<number>(0.0);
	
	const handleValue1Change = (e: ChangeEvent<HTMLInputElement>) => {
		setValue1(parseFloat(e.target.value));
	};
	
	const handleValue2Change = (e: ChangeEvent<HTMLInputElement>) => {
		setValue2(parseFloat(e.target.value));
	};
	
	const handleClose = () => setShowModal(false);
	
	const placeOrder = async () => {
		if (!walletProvider) {
			alert('Please connect your wallet');
			return;
		}
		
		const contract = await GET_CONTRACT(walletProvider);
		
		try {
			dispatch(setLoading(true));
			// Use the correct integer value for OrderType.SELL
			const tx = await contract.placeMarketOrder(
				OrderType.SELL,
				selectedToken1.address,
				selectedToken2.address,
				parseUnits(value1.toString()),
			);
			console.log('Transaction sent:', tx);
			const receipt = await tx.wait();
			dispatch(setLoading(false));
			setTxhash(receipt.hash);
			setShowModal(true);
			console.log('Transaction confirmed:', receipt);
		} catch (e) {
			dispatch(setLoading(false));
			console.log('error: ', e);
		}
	};
	
	return (
		<div className="card rounded-5" style={{ width: '32rem' }}>
			<SwapTabs />
			<div className="card-body">
				<div className="bg-gray rounded-4 p-3">
					<div className="d-flex justify-content-between">
						<DropdownWithSearch token={selectedToken1} changeTokenCallback={setSelectedToken1} />
						<input
							type="number"
							className={`fs-4 form-control w-25 bg-gray border-0 text-end ${S.noArrows}`}
							placeholder="0.0"
							value={value1}
							onChange={handleValue1Change}
						/>
					</div>
					<div
						className="mt-2 d-flex fw-light fs-13">Balance: {balance.toFixed(1)} {selectedToken1.symbol}</div>
				</div>
				
				<div className="bg-gray rounded-4 p-3 mt-3">
					<div className={`${S.pAbsolute}`}><i className="bi-arrow-down-short fs-4" /></div>
					<div className="d-flex justify-content-between">
						<DropdownWithSearch token={selectedToken2} changeTokenCallback={setSelectedToken2} />
						<input
							type="number"
							className={`fs-4 form-control w-25 bg-gray border-0 text-end ${S.noArrows}`}
							placeholder="0.0"
							value={value2}
							onChange={handleValue2Change}
						/>
					</div>
					<div
						className="mt-2 d-flex fw-light fs-13">Balance: {balance.toFixed(1)} {selectedToken2.symbol}
					</div>
				</div>
				
				<div className={`${S.sellButton} rounded-4 p-3 mt-3 c-pointer`}
					 onClick={placeOrder}>
					
					Sell ${selectedToken1.symbol}
				</div>
			</div>
			<ModalComponent show={showModal} handleClose={handleClose} txHash={txHash}
							title={CONFIRMED} />
		</div>
	);
}

export default SwapComponent;
