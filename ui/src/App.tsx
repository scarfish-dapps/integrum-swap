import React from 'react';
import './App.css';
import backgroundUrl from './assets/cover.png';
import Swap from "./pages/Swap";
import { Route, Routes } from "react-router-dom";
import Limit from "./pages/Limit";
import Spinner from "./components/spiner/Spiner";
import { useAppSelector } from "./store/hooks";
import NavBar from "./components/navBar/NavBar";

function App() {
	const isLoading = useAppSelector((state) => state.spinner.isLoading);
	
	return (
		<div className="App" style={{ backgroundImage: `url(${backgroundUrl})` }}>
			{isLoading && <Spinner />}
			<NavBar />
			<Routes>
				<Route path="/" element={<Swap />} />
				<Route path="/limit" element={<Limit />} />
				<Route path="/swap" element={<Swap />} />
			</Routes>
		</div>
	);
}

export default App;
