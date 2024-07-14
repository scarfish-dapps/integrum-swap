import { configureStore } from '@reduxjs/toolkit';
import userReducer from './user/userSlice';
import spinnerReducer from './spiner/spinerSlice';

export const store = configureStore({
	reducer: {
		user: userReducer,
		spinner: spinnerReducer,
	},
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export default store;
