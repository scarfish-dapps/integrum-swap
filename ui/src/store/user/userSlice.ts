import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface UserState {
	address: string;
	balance: number;
}

const initialState: UserState = {
	address: '',
	balance: 0
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
	},
});

export const { setAddress, setBalance } = userSlice.actions;

export default userSlice.reducer;
