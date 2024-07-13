import React, { useState, ChangeEvent } from 'react';
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import S from './index.module.css';
import DropdownWithSearch from "../DropdownWithSearch.tsx/DropdownWithSearch";
import { Token } from "../../client/tokens";
import { CONFIRMED, ERC20_TOKENS, OrderType } from "../../utils";
import SwapTabs from "../swapTabs/SwapTabs";
import { parseUnits } from "ethers";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";
import ModalComponent from "../modal/Modal";
import { setLoading } from "../../store/spiner/spinerSlice";
import { GET_CONTRACT } from "../../ContractUtils";

const LimitSwap: React.FC = () => {
	const { walletProvider } = useWeb3ModalProvider();
	const dispatch = useAppDispatch();
	
	const balance = useAppSelector((state) => state.user.balance);
	const [limitValue, setLimitValue] = useState<number>(0.0);
	const [showModal, setShowModal] = useState(false);
	const [txHash, setTxhash] = useState('');
	const [message, setMessage] = useState('');
	
	const [value1, setValue1] = useState<number>(0.0);
	const [selectedToken1, setSelectedToken1] = useState<Token>(ERC20_TOKENS[0]);
	
	const [value2, setValue2] = useState<number>(0.0);
	const [selectedToken2, setSelectedToken2] = useState<Token>(ERC20_TOKENS[1]);
	
	
	const handleClose = () => setShowModal(false);
	
	const handleValue1Change = (e: ChangeEvent<HTMLInputElement>) => {
		setValue1(parseFloat(e.target.value));
	};
	
	const handleValue2Change = (e: ChangeEvent<HTMLInputElement>) => {
		setValue2(parseFloat(e.target.value));
	};
	
	const handleLimitValueChange = (e: ChangeEvent<HTMLInputElement>) => {
		setLimitValue(parseFloat(e.target.value));
	};
	
	const limitOrder = async () => {
		if (!walletProvider) {
			alert('Please connect your wallet');
			return;
		}
		
		const contract = await GET_CONTRACT(walletProvider);
		console.log('contract details: ', contract);
		
		try {
			dispatch(setLoading(true));
			// Use the correct integer value for OrderType.SELL
			const tx = await contract.placeLimitOrder(
				OrderType.SELL,
				selectedToken1.address,
				selectedToken2.address,
				parseUnits(value1.toString(), 18),
				parseUnits(limitValue.toString(), 18)
			);
			console.log('Transaction sent:', tx);
			const receipt = await tx.wait();
			dispatch(setLoading(false));
			setTxhash(receipt.hash);
			setMessage(CONFIRMED);
			setShowModal(true);
			
			console.log('Transaction confirmed:', receipt);
		} catch (e) {
			dispatch(setLoading(false));
			console.log('error: ', e);
		}
	};
	
	const limitPriceReceive = value1 * limitValue ? value1 * limitValue : 0;
	
	return (
		<div className="card rounded-5" style={{ width: '52rem' }}>
			<SwapTabs />
			<div className="card-body">
				<div className="bg-gray rounded-4 p-3 ">
					<div className="d-flex justify-content-between">
						<DropdownWithSearch token={selectedToken1}
											changeTokenCallback={token => setSelectedToken1(token)} />
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
				
				<div className="bg-gray rounded-4 p-3 pt-1 pb-1 mt-3">
					<div className="d-flex justify-content-between align-items-center">
						<div className="text-start">
							Limit price:
							<div className="fw-light fs-13">(Minimum <span
								className="fw-bold">${selectedToken2.symbol}</span> revice
								per <span className="fw-bold">${selectedToken1.symbol}</span>)</div>
						</div>
						<input
							type="number"
							className={`fs-4 form-control w-25 bg-gray border-0 text-end ${S.noArrows}`}
							placeholder="0.0"
							value={limitValue}
							onChange={handleLimitValueChange}
						/>
					</div>
				</div>
				
				<div style={{ height: '1px' }} className="bg-gray mt-4 rounded-5 mb-4">
					<div className={`${S.pAbsolute}`}><i className="bi-arrow-down-short fs-4" /></div>
				</div>
				
				<div className="bg-gray rounded-4 p-3 mt-3">
					
					<div className="d-flex justify-content-between">
						<DropdownWithSearch token={selectedToken2}
											changeTokenCallback={token => setSelectedToken2(token)} />
						
						<div className="text-end fs-4">{(limitPriceReceive).toFixed(2)}</div>
					</div>
					<div
						className="mt-2 d-flex fw-light fs-13">Balance: {balance.toFixed(1)} {selectedToken2.symbol}</div>
				</div>
				
				<div className={`${S.sellButton} rounded-4 p-3 mt-3 c-pointer`}
					 onClick={limitOrder}
				>
					Sell ${selectedToken1.symbol}
				</div>
			</div>
			<ModalComponent show={showModal} handleClose={handleClose} txHash={txHash}
							title={message} />
		</div>
	);
}

export default LimitSwap;
