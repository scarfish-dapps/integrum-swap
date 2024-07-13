import React, { useState, ChangeEvent, useEffect } from 'react';
import { Dropdown, DropdownToggle, DropdownMenu, DropdownItem } from 'reactstrap';
import { fetchTokens, Token } from "../../client/tokens";
import { ERC20_TOKENS } from "../../utils";

interface DropdownWithSearchProps {
	token: Token | null;
	changeTokenCallback: (token: Token) => void;
}

const DropdownWithSearch: React.FC<DropdownWithSearchProps> = ({ token, changeTokenCallback }) => {
	const [dropdownOpen, setDropdownOpen] = useState(false);
	const [searchTerm, setSearchTerm] = useState('');
	const [tokens, setTokens] = useState<Token[]>(ERC20_TOKENS);
	
	// useEffect(() => {
	// 	(async () => {
	// 		const tokens = await fetchTokens();
	// 		setTokens(tokens)
	// 	})();
	// }, []);
	
	const toggle = () => setDropdownOpen(!dropdownOpen);
	
	const handleSearch = (event: ChangeEvent<HTMLInputElement>) => {
		setSearchTerm(event.target.value);
	};
	
	const handleSelectItem = (item: Token) => {
		changeTokenCallback(item);
		setDropdownOpen(false);
	};
	
	const filteredItems = tokens.filter(item =>
		item.symbol.toLowerCase().includes(searchTerm.toLowerCase())
	);
	
	const selectedTokenStyle = token ? " bg-white text-black" : "bg-main c-aqua"
	
	return (
		<Dropdown isOpen={dropdownOpen} toggle={toggle}>
			<DropdownToggle caret className={`rounded-5 fw-bold ${selectedTokenStyle}`}>
				{token ? <span>
					<img src={token.icon_url} alt={token.symbol} className="me-2"
						 style={{ width: '20px' }} />
					{token.symbol}
				</span> : 'Select a token'}
			</DropdownToggle>
			<DropdownMenu style={{ maxHeight: '250px', overflow: "auto" }}>
				<div className="p-2">
					<input
						type="text"
						className="form-control"
						placeholder="Search..."
						value={searchTerm}
						onChange={handleSearch}
					/>
				</div>
				{filteredItems.map((item, index) => (
					<DropdownItem key={index} onClick={() => handleSelectItem(item)}>
						<img src={item.icon_url} alt={item.symbol} className="me-2" style={{ width: '20px' }} />
						{item.symbol}
					</DropdownItem>
				))}
			</DropdownMenu>
		</Dropdown>
	);
};

export default DropdownWithSearch;
