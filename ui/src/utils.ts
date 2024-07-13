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


export const ERC20_TOKENS:Token[] = [
	{
		address:'0x41eE3643D5C2eD4a2D092a212E613340076a317e',
		decimals:'18',
		icon_url:'https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png',
		name:'Wrapped Ether',
		symbol:'WETH'
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