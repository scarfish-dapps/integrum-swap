import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface SpinnerState {
	isLoading: boolean;
	transactionHash: string;
}

const initialState: SpinnerState = {
	isLoading: false,
	transactionHash: '',
};

export const spinnerSlice = createSlice({
	name: 'spinner', // Add the name of the slice
	initialState,
	reducers: {
		setLoading: (state, action: PayloadAction<boolean>) => {
			state.isLoading = action.payload;
		},
		setTransactionHash: (state, action: PayloadAction<string>) => {
			state.transactionHash = action.payload;
		},
	},
});

export const { setLoading, setTransactionHash } = spinnerSlice.actions;

export default spinnerSlice.reducer;
