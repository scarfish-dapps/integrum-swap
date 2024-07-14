import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface Chain {
	chainId: number;
	name: string;
	img: string;
	currency: string;
	explorerUrl: string;
	rpcUrl: string;
}

interface UserState {
	address: string;
	balance: number;
	chain: Chain;
}

const initialState: UserState = {
	address: '',
	balance: 0,
	chain: {
		chainId: 11155111,
		name: 'Sepolia',
		img: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAbCAMAAABY1h8eAAAAV1BMVEVHcEw2P/o2P/k2P/k2P/o2P/k2P/s2P/w2P/s2P/o2P/k2P/k2P/klMPnw8P719f8uOPmwsvzs7P6go/wYJfl2evvMzf2Jjfvh4v5bYfo/SPm6vP1IT/nT7oRhAAAADHRSTlMAbPiI3sFVHjnsg6KEiqV2AAAA60lEQVQokYVS7RKDIAxDJyKOUr5U5nz/55wToeruXH5wQK5NKGEso3twqZTkj45dUdWqQFYnSkh1QiOIa9UPuhuusIJu5pn2qTPphfENpLv5LEczIL5MObYrSW+A0bkxHEs7UgkDOpyoVLC+7JcY1lKnClsxTm7QK+30uzR+sobcODReO/LECwnRuQgQESNcSdhqAJZhGKhy11zQaQs+Yc6a/e5m9Rks6i9w91Sld5oJNU6vxK1s6izShIy31ofJZmyTaPJsDQBsS4LJs2WXFBxGe/7PI8T/JNxn6D5919y2P7H+Jr6uJe+p4wcuvx7WFAdqoAAAAABJRU5ErkJggg==',
		currency: 'ETH',
		explorerUrl: 'https://sepolia.etherscan.io',
		rpcUrl: 'https://rpc.sepolia.org'
	}
};

export const userSlice = createSlice({
	name: 'user',
	initialState,
	reducers: {
		setAddress: (state, action: PayloadAction<string>) => {
			state.address = action.payload;
		},
		setBalance: (state, action: PayloadAction<number>) => {
			state.balance = action.payload;
		},
		setChain: (state, action: PayloadAction<Chain>) => {
			state.chain = action.payload;
		},
	},
});

export const { setAddress, setBalance, setChain } = userSlice.actions;

export default userSlice.reducer;
