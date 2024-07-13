import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import { createWeb3Modal, defaultConfig } from '@web3modal/ethers/react';
import { Provider } from 'react-redux';
import store from './store/store';
import App from './App';
import { BrowserRouter } from "react-router-dom";

const projectId = '8ecc0ab4f5d37a554193f0a4552b99ab';
const sepolia = {
	chainId: 11155111,
	name: 'Sepolia',
	currency: 'ETH',
	explorerUrl: 'https://sepolia.etherscan.io',
	rpcUrl: 'https://rpc.sepolia.org'
}

const arbSepolia = {
	chainId: 421614,
	name: 'ArbSepolia',
	currency: 'ETH',
	explorerUrl: 'https://sepolia.arbiscan.io/',
	rpcUrl: 'https://sepolia-rollup.arbitrum.io/rpc'
}

const bscTestnet = {
	chainId: 97,
	name: 'BSC Testnet',
	currency: 'BNB',
	explorerUrl: 'https://explorer.binance.org/smart-testnet',
	rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545'
}


const mainnet = {
	chainId: 1,
	name: 'Ethereum Mainnet',
	currency: 'ETH',
	explorerUrl: 'https://etherscan.io',
	rpcUrl: 'https://ethereum-rpc.publicnode.com'
}

const metadata = {
	name: 'Integrum Swap',
	description: 'AppKit Example',
	url: 'https://web3modal.com', // origin must match your domain & subdomain
	icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const ethersConfig = defaultConfig({
	/*Required*/
	metadata,
	
	/*Optional*/
	enableEIP6963: true, // true by default
	enableInjected: true, // true by default
	enableCoinbase: true, // true by default
	rpcUrl: '...', // used for the Coinbase SDK
	defaultChainId: 1, // used for the Coinbase SDK
})

createWeb3Modal({
	ethersConfig,
	chains: [arbSepolia,bscTestnet, sepolia, mainnet],
	projectId,
	enableAnalytics: true // Optional - defaults to your Cloud configuration
})

const root = ReactDOM.createRoot(
	document.getElementById('root') as HTMLElement
);
root.render(
	<React.StrictMode>
		<Provider store={store}>
			<BrowserRouter>
				<App />
			</BrowserRouter>
		</Provider>
	</React.StrictMode>
);

export default function ConnectButton() {
	return <w3m-button />
}