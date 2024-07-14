import { Token } from "./client/tokens";

export const trimAddress = (address: string = '') => {
	if (address.length <= 10) {
		return address;
	}
	return address.slice(0, 6) + '...' + address.slice(-4);
}

export enum ChainId {
	Mainnet = 1,
	Sepolia = 11155111,
	ArbitrumSepolia = 421614,
	Bsctestnet = 97,
}

export enum SwapType {
	Swap = 'SWAP',
	Limit = 'LIMIT'
}


export const ERC20_TOKENS: Token[] = [
	{
		address: '0x41eE3643D5C2eD4a2D092a212E613340076a317e',
		decimals: '18',
		icon_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
		name: 'Wrapped Ether',
		symbol: 'WETH'
	},
	{
		address: '0xaAe29B0366299461418F5324a79Afc425BE5ae21',
		decimals: '18',
		icon_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/4943.png',
		name: 'Dai Stablecoin',
		symbol: 'DAI'
	},
	{
		address: '0x30fA2FbE15c1EaDfbEF28C188b7B8dbd3c1Ff2eB',
		decimals: '6',
		icon_url: 'https://s2.coinmarketcap.com/static/img/coins/64x64/825.png',
		name: 'Tether USD',
		symbol: 'USDT'
	}
]

export enum OrderType {
	BUY = 0,
	SELL = 1
}

export const CONFIRMED = 'Transaction Confirmed 🎉';

export const getTokenByAddress = (address: string): Token | undefined => {
	return ERC20_TOKENS.find(token => token.address === address);
}

export const CHAINS = [
	{
		chainId: 11155111,
		name: 'Sepolia',
		img: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAbCAMAAABY1h8eAAAAV1BMVEVHcEw2P/o2P/k2P/k2P/o2P/k2P/s2P/w2P/s2P/o2P/k2P/k2P/klMPnw8P719f8uOPmwsvzs7P6go/wYJfl2evvMzf2Jjfvh4v5bYfo/SPm6vP1IT/nT7oRhAAAADHRSTlMAbPiI3sFVHjnsg6KEiqV2AAAA60lEQVQokYVS7RKDIAxDJyKOUr5U5nz/55wToeruXH5wQK5NKGEso3twqZTkj45dUdWqQFYnSkh1QiOIa9UPuhuusIJu5pn2qTPphfENpLv5LEczIL5MObYrSW+A0bkxHEs7UgkDOpyoVLC+7JcY1lKnClsxTm7QK+30uzR+sobcODReO/LECwnRuQgQESNcSdhqAJZhGKhy11zQaQs+Yc6a/e5m9Rks6i9w91Sld5oJNU6vxK1s6izShIy31ofJZmyTaPJsDQBsS4LJs2WXFBxGe/7PI8T/JNxn6D5919y2P7H+Jr6uJe+p4wcuvx7WFAdqoAAAAABJRU5ErkJggg==',
		currency: 'ETH',
		explorerUrl: 'https://sepolia.etherscan.io',
		rpcUrl: 'https://rpc.sepolia.org'
	},
	{
		chainId: 44787,
		name: 'Celo',
		img: 'https://s2.coinmarketcap.com/static/img/coins/64x64/5567.png',
		currency: 'CELO',
		explorerUrl: 'https://explorer.celo.org/alfajores',
		rpcUrl: 'https://alfajores-forno.celo-testnet.org'
	},
	{
		chainId: 84532,
		name: 'Base',
		img: 'https://s2.coinmarketcap.com/static/img/coins/64x64/27716.png',
		currency: 'ETH',
		explorerUrl: 'https://base-sepolia.blockscout.com',
		rpcUrl: 'https://sepolia.base.org'
	},
	{
		chainId: 11155420,
		name: 'Optimism',
		img:'https://s2.coinmarketcap.com/static/img/coins/64x64/11840.png',
		currency: 'ETH',
		explorerUrl: 'https://optimism-sepolia.blockscout.com/',
		rpcUrl: 'https://endpoints.omniatech.io/v1/op/sepolia/public'
	},
	{
		chainId: 59141,
		name: 'Linea',
		img: 'https://s2.coinmarketcap.com/static/img/coins/64x64/27657.png',
		currency: 'ETH',
		explorerUrl: 'https://explorer.sepolia.linea.build/',
		rpcUrl: 'https://linea-sepolia.blockpi.network/v1/rpc/public'
	}
];
