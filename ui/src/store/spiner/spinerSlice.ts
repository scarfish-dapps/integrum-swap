import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface SpinnerState {
	isLoading: boolean;
}

const initialState: SpinnerState = {
	isLoading: false
};

export const spinnerSlice = createSlice({
	name: 'spinner', // Add the name of the slice
	initialState,
	reducers: {
		setLoading: (state, action: PayloadAction<boolean>) => {
			state.isLoading = action.payload;
		},
	},
});

export const { setLoading } = spinnerSlice.actions;

export default spinnerSlice.reducer;
