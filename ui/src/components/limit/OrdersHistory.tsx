import React, { useEffect, useState } from "react";
import styles from "./index.module.css";
import { useWeb3ModalProvider } from "@web3modal/ethers/react";
import { getTokenByAddress, trimAddress } from "../../utils";
import { GET_CONTRACT } from "../../ContractUtils";

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

const ordersIdx = [0, 1, 2, 3, 4, 5];

const OrdersHistory: React.FC = () => {
	const { walletProvider } = useWeb3ModalProvider();
	const [isLoading, setIsLoading] = useState(false);
	const [orders, setOrders] = useState<any[]>([]);
	
	useEffect(() => {
		if (walletProvider) {
			getOrders();
		}
	}, [walletProvider]);
	
	const getOrders = async () => {
		setIsLoading(true);
		const contract = await GET_CONTRACT(walletProvider);
		try {
			// Fetch all orders concurrently
			const ordersData = await Promise.all(
				ordersIdx.map(async (index) => {
					const orderResponse = await contract.retrieveLimitOrder(index);
					return {
						id: orderResponse[0].toString(),
						user: orderResponse[1],
						orderType: orderResponse[2].toString(),
						token0: orderResponse[3],
						token1: orderResponse[4],
						amount: orderResponse[5].toString(),
						price: orderResponse[6].toString(),
						isFilled: orderResponse[7],
						isCanceled: orderResponse[8],
					};
				})
			);
			
			console.log('Formatted Orders:', ordersData);
			setOrders(ordersData);
			setIsLoading(false);
		} catch (e) {
			setIsLoading(false);
			console.log('error: ', e);
		}
	}
	
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
			<th>order Id</th>
			<th>Swap <i className="ms-2 bi bi-arrow-left-right"></i></th>
			<th>User</th>
			<th>STATUS</th>
			<th>Actions</th>
		</tr>
		</thead>
	);
	
	const row = ({ id, amount, orderType, token0, token1, isCanceled, isFilled, user, price }: OrderResponse) => (
		<tr className="bg-danger">
			<td>{id}</td>
			<td>
				<span>
					{getTokenByAddress(token0)?.symbol} {amount}</span>
				<i className="bi-arrow-right-short"></i>
				<span> {Number(amount) * Number(price)} {getTokenByAddress(token1)?.symbol}</span>
			</td>
			<td>{trimAddress(user)}</td>
			<td className={`${isFilled ? 'text-danger' : 'text-success'} fw-bold`}>{isFilled ? 'FILLED' : 'OPEN'}</td>
			<td>
				<button className={`btn btn-primary bg-main border-0  ${isFilled && 'disabled'}`}>Cancel</button>
			</td>
		</tr>
	);
	
	return (
		<div className="card w-100 ms-4 bg-transparent p-0 border-0">
			<div className="text-start fs-4 text-white fw-bold mb-3">Your orders</div>
			<div className="card-body p-0">
				{isLoading ? spinner() : (
					<table
						className={`table table-striped table-hover bg-transparent text-white ${styles.roundedTable}`}>
						{header()}
						<tbody>
						{orders.map((order, index) => (
							row(order)
						))}
						</tbody>
					</table>
				)}
			</div>
		</div>
	);
}

export default OrdersHistory;
