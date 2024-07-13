import React, { useEffect, useState } from "react";
import styles from "./index.module.css";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";
import { getTokenByAddress, trimAddress } from "../../utils";
import { GET_CONTRACT } from "../../ContractUtils";
import { setLoading } from "../../store/spiner/spinerSlice";
import { useAppDispatch } from "../../store/hooks";
import ModalComponent from "../modal/Modal";

interface OrderResponse {
	id: string;
	user: string;
	orderType: string;
	token0: string;
	token1: string;
	amount: string;
	price: string;
	isFilled: boolean;
	isCanceled: boolean;
}

const OrdersHistory: React.FC = () => {
	const dispatch = useAppDispatch();
	const { walletProvider } = useWeb3ModalProvider();
	const [isLoading, setIsLoading] = useState(false);
	const [orders, setOrders] = useState<OrderResponse[]>([]);
	const [showModal, setShowModal] = useState(false);
	const [txHash, setTxHash] = useState('');
	const [message, setMessage] = useState('');
	
	useEffect(() => {
		if (walletProvider) {
			getOrdersLength().then((length) => {
				if (length > 0) {
					getOrders(length);
				} else {
					setIsLoading(false);
				}
			});
		}
	}, [walletProvider]);
	
	const getOrdersLength = async (): Promise<number> => {
		const contract = await GET_CONTRACT(walletProvider);
		const ordersLength = await contract.getOrdersLength();
		console.log('Orders length:', ordersLength);
		return Number(ordersLength);
	};
	
	const getOrders = async (length: number) => {
		setIsLoading(true);
		const contract = await GET_CONTRACT(walletProvider);
		try {
			const ordersData = await Promise.all(
				Array.from({ length }, (_, index) => contract.retrieveLimitOrder(index))
			);
			
			const formattedOrders = ordersData.map((orderResponse) => ({
				id: orderResponse[0].toString(),
				user: orderResponse[1],
				orderType: orderResponse[2].toString(),
				token0: orderResponse[3],
				token1: orderResponse[4],
				amount: orderResponse[5].toString(),
				price: orderResponse[6].toString(),
				isFilled: orderResponse[7],
				isCanceled: orderResponse[8],
			}));
			
			console.log('Formatted Orders:', formattedOrders);
			setOrders(formattedOrders);
			setIsLoading(false);
		} catch (e) {
			setIsLoading(false);
			console.log('error: ', e);
		}
	};
	
	const handleClose = () => setShowModal(false);
	
	const cancelOrder = async (orderId: number) => {
		if (!walletProvider) {
			alert('Please connect your wallet');
			return;
		}
		const contract = await GET_CONTRACT(walletProvider);
		try {
			dispatch(setLoading(true));
			const tx = await contract.cancelLimitOrder(orderId);
			console.log('Transaction sent:', tx);
			const receipt = await tx.wait();
			dispatch(setLoading(false));
			setTxHash(receipt.transactionHash);
			setMessage('Order Cancelled');
			setShowModal(true);
			console.log('Transaction confirmed:', receipt);
		} catch (e) {
			dispatch(setLoading(false));
			console.log('error: ', e);
		}
	};
	
	const spinner = () => (
		<div className={styles.spinnerContainer}>
			<div className="spinner-border text-primary" role="status">
				<span className="visually-hidden">Loading...</span>
			</div>
		</div>
	);
	
	const header = () => (
		<thead>
		<tr className="fw-bold">
			<th>Order Id</th>
			<th>Swap <i className="ms-2 bi bi-arrow-left-right"></i></th>
			<th>User</th>
			<th>Status</th>
			<th>Actions</th>
		</tr>
		</thead>
	);
	
	const row = ({ id, amount, token0, token1, isFilled, user, price }: OrderResponse) => (
		<tr key={id} className="bg-danger">
			<td>{id}</td>
			<td>
				<span>{getTokenByAddress(token0)?.symbol} {amount}</span>
				<i className="bi-arrow-right-short"></i>
				<span> {Number(amount) * Number(price)} {getTokenByAddress(token1)?.symbol}</span>
			</td>
			<td>{trimAddress(user)}</td>
			<td className={`${isFilled ? 'text-danger' : 'text-success'} fw-bold`}>{isFilled ? 'FILLED' : 'OPEN'}</td>
			<td>
				<button
					className={`btn btn-primary bg-main border-0  ${isFilled && 'disabled'}`}
					onClick={() => cancelOrder(Number(id))}
					disabled={isFilled}
				>
					Cancel
				</button>
			</td>
		</tr>
	);
	
	return (
		<div className="card w-100 ms-4 bg-transparent p-0 border-0">
			<div className="text-start fs-4 text-white fw-bold mb-3">Your orders</div>
			<div className="card-body p-0">
				{isLoading ? (
					spinner()
				) : orders.length > 0 ? (
					<table
						className={`table table-striped table-hover bg-transparent text-white ${styles.roundedTable}`}>
						{header()}
						<tbody>
						{orders.map(row)}
						</tbody>
					</table>
				) : (
					<div className="text-center c-main bg-white rounded-5 p-3">No orders found.</div>
				)}
			</div>
			<ModalComponent show={showModal} handleClose={handleClose} txHash={txHash} title={message} />
		</div>
	);
};

export default OrdersHistory;
