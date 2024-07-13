import React, { useEffect, useState } from "react";
import { ChainId, trimAddress } from "../../utils";
import { useWalletInfo, useSwitchNetwork, useWeb3ModalAccount } from "@web3modal/ethers/react";
import { useAppSelector } from "../../store/hooks";

interface WalletProfileProps {
	openModalCallback?: () => void;
}

function WalletProfile({ openModalCallback }: WalletProfileProps) {
	const [selectedNetwork, setSelectedNetwork] = useState('Ethereum');
	const { walletInfo } = useWalletInfo()
	const { address, chainId, isConnected } = useWeb3ModalAccount()
	const { switchNetwork } = useSwitchNetwork();
	const balance = useAppSelector((state) => state.user.balance);
	
	useEffect(() => {
		if (chainId === ChainId.Mainnet) {
			setSelectedNetwork('Ethereum');
		}
		if (chainId === ChainId.Sepolia) {
			setSelectedNetwork('Sepolia');
		}
		if (chainId === ChainId.ArbitrumSepolia) {
			setSelectedNetwork('Arb Sepolia');
		}
		
		if (chainId === ChainId.Bsctestnet) {
			setSelectedNetwork('BSC Testnet');
		}
	}, [chainId]);
	
	const handleNetworkChange = async (chainId: number) => {
		await switchNetwork(chainId);
		if (chainId === ChainId.Mainnet) {
			setSelectedNetwork('Ethereum');
		}
		if (chainId === ChainId.Sepolia) {
			setSelectedNetwork('Sepolia');
		}
		
		if (chainId === ChainId.Bsctestnet) {
			setSelectedNetwork('BSC Testnet');
		}
	}
	
	const networkIcon = selectedNetwork === 'Ethereum' ? 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png' : 'https://moralis.io/wp-content/uploads/web3wiki/1556-sepolia-faucet/6407bf22774da86b23788f3a_alchemy-mark-blue-gradient.png';
	
	return (
		<div className="d-flex">
			<div className="dropdown">
				<button className="btn rounded-pill dropdown-toggle" type="button" data-bs-toggle="dropdown"
						aria-expanded="false">
					<img src={networkIcon} alt="Ethereum"
						 width="20" />
					<span className="me-2 ms-2">{selectedNetwork}</span>
				</button>
				<ul className="dropdown-menu">
					<div className="ms-2">Select network</div>
					<li onClick={() => handleNetworkChange(ChainId.ArbitrumSepolia)}><a className="dropdown-item"
																						href="#">
						<img
							src="https://moralis.io/wp-content/uploads/web3wiki/1556-sepolia-faucet/6407bf22774da86b23788f3a_alchemy-mark-blue-gradient.png"
							alt="Ethereum"
							width="20" />
						<span className="ms-2">ARB Sepolia</span>
					</a></li>
					<li onClick={() => handleNetworkChange(ChainId.Sepolia)}><a className="dropdown-item" href="#">
						<img
							src="https://moralis.io/wp-content/uploads/web3wiki/1556-sepolia-faucet/6407bf22774da86b23788f3a_alchemy-mark-blue-gradient.png"
							alt="Ethereum"
							width="20" />
						<span className="ms-2">Sepolia</span>
					</a></li>
					<li onClick={() => handleNetworkChange(ChainId.Mainnet)}><a className="dropdown-item" href="#">
						<img src="https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png" alt="Ethereum"
							 width="20" />
						<span className="ms-2">Ethereum</span>
					</a></li>
					<li onClick={() => handleNetworkChange(ChainId.Bsctestnet)}><a className="dropdown-item" href="#">
						<img
							src="https://s2.coinmarketcap.com/static/img/coins/64x64/1839.png"
							alt="BSC"
							width="20" />
						<span className="ms-2">BSC Testnet</span>
					</a></li>
				</ul>
			</div>
			<div onClick={openModalCallback}
				 className="d-flex align-items-center bg-gray rounded-pill  me-2 p-1 c-pointer">
				<div className="me-3 ms-3 fw-light fs-13">
					{balance.toFixed(5)} ETH
				</div>
				<div className="me-2 rounded-pill bg-white ps-2 pe-2 pt-1 pb-1">
					{trimAddress(address)}
					<img src={walletInfo?.icon} alt="Wallet" width="18" height="18"
						 className="d-inline-block align-text-top ms-2 me-2" />
				</div>
				<div className="me-2 ms-2 fw-bold">
					<i className="bi bi-bell"></i>
				</div>
			</div>
		</div>
	);
}

export default WalletProfile;