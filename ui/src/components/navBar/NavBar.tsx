import React, { useEffect } from 'react';
import logo from '../../assets/integrum.png'; // Adjust the path according to the actual location
import S from './index.module.css';
import { BrowserProvider, formatEther } from 'ethers';
import { useWeb3ModalAccount, useWeb3ModalProvider, useWeb3Modal } from "@web3modal/ethers/react";
import WalletProfile from "../../components/walletProfile/WalletProfile";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { setBalance } from "../../store/user/userSlice";
import { useNavigate } from 'react-router-dom';


function NavBar() {
	const { address, isConnected } = useWeb3ModalAccount();
	const { walletProvider } = useWeb3ModalProvider();
	const { open, close } = useWeb3Modal()
	const dispatch = useAppDispatch();
	const navigate = useNavigate();
	const selectedNetwork = useAppSelector((state) => state.user.chain);
	
	useEffect(() => {
		const fetchBalance = async () => {
			if (walletProvider && address) {
				const ethersProvider = new BrowserProvider(walletProvider);
				const balance = await ethersProvider.getBalance(address);
				const formattedBalance = formatEther(balance);
				dispatch(setBalance(Number(formattedBalance)))
			}
		};
		
		if (isConnected) {
			fetchBalance();
		}
	}, [walletProvider, address, isConnected, selectedNetwork]);
	
	return (
		<nav className={`navbar ${S.navBar} border-0 rounded-5 z-3`}>
			<div className="d-flex align-items-center">
				<a className="navbar-brand ms-2" href="#">
					<img src={logo} alt="Logo" width="30" height="30"
						 className="d-inline-block align-text-top me-3 ms-3" />
					<span className="fw-bold text-black">Integrum Swap</span>
				</a>
				<div className={`${S.button} me-1 border-0 p-2 rounded-5`} onClick={() => navigate('/swap')}>
					Swap
				</div>
				<div className={`${S.button} me-1 border-0 p-2 rounded-5`} onClick={() => navigate('/limit')}>
					Limit
				</div>
				<div className={`${S.button} me-1 border-0 p-2 rounded-5`}>
					About
				</div>
			</div>
			
			<div className="float-end d-flex">
				{isConnected ? <WalletProfile openModalCallback={() => open()} /> : <w3m-button />}
			</div>
		</nav>
	);
}

export default NavBar;
