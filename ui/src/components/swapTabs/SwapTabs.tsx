import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from "react-router-dom";
import S from './index.module.css';
import { SwapType } from "../../utils";

function SwapTabs() {
	const location = useLocation();
	const navigate = useNavigate();
	const [activeTab, setActiveTab] = useState<SwapType>(SwapType.Swap);
	
	useEffect(() => {
		const path = location.pathname.toLowerCase();
		if (path.includes(SwapType.Limit.toLowerCase())) {
			setActiveTab(SwapType.Limit);
		} else {
			setActiveTab(SwapType.Swap);
		}
	}, [location.pathname]);
	
	const isActive = (tab: string) => (activeTab === tab ? 'bg-gray' : '');
	
	const handleClick = (tab: SwapType) => {
		setActiveTab(tab);
		navigate(`/${tab.toLowerCase()}`);
	}
	
	return (
		<div className="mt-1 p-1">
			<div
				className={`btn btn-sm ms-3 ${isActive(SwapType.Swap)} rounded-pill mt-2 ps-2 pe-2 float-start fw-bold ${S.tab}`}
				onClick={() => handleClick(SwapType.Swap)}
			>
				Swap
			</div>
			<div
				className={`btn btn-sm ms-3 ${isActive(SwapType.Limit)} rounded-pill mt-2 ps-2 pe-2 float-start fw-bold ${S.tab}`}
				onClick={() => handleClick(SwapType.Limit)}
			>
				Limit
			</div>
		</div>
	);
}

export default SwapTabs;
