import axios, { AxiosResponse } from 'axios';

interface ResponseToken {
	items: Token[];
	next_page_params: {
		contract_address_hash: string;
		fiat_value: null | number;
		holder_count: number;
		is_name_null: boolean;
		items_count: number;
		market_cap: null | number;
		name: string;
	}
}

export interface Token {
	address: string;
	decimals: string;
	icon_url: string;
	name: string;
	symbol: string;
}

export const fetchTokens = async (token: string = ''): Promise<Token[]> => {
	try {
		const response = await axios.get('https://base-sepolia.blockscout.com/api/v2/tokens', {
			params: {
				q: token,
				type: 'ERC-20'
			}
		}) as AxiosResponse<ResponseToken>;
		console.log(response.data.items);
		return response.data.items;
	} catch (error) {
		console.error('Error fetching tokens:', error);
		return [];
	}
};