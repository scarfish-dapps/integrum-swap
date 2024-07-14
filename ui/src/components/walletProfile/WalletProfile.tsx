import React from "react";
import { CHAINS, trimAddress } from "../../utils";
import { useWalletInfo, useSwitchNetwork, useWeb3ModalAccount } from "@web3modal/ethers/react";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { Chain, setChain } from "../../store/user/userSlice";

interface WalletProfileProps {
	openModalCallback?: () => void;
}

function WalletProfile({ openModalCallback }: WalletProfileProps) {
	const dispatch = useAppDispatch();
	const selectedNetwork = useAppSelector((state) => state.user.chain);
	
	const { walletInfo } = useWalletInfo()
	const { address, chainId, isConnected } = useWeb3ModalAccount()
	const { switchNetwork } = useSwitchNetwork();
	const balance = useAppSelector((state) => state.user.balance);
	
	
	const handleNetworkChange = async (chain: Chain) => {
		await switchNetwork(chain.chainId);
		dispatch(setChain(chain));
	}
	
	return (
		<div className="d-flex">
			<div className="dropdown">
				<button className="btn rounded-pill dropdown-toggle" type="button" data-bs-toggle="dropdown"
						aria-expanded="false">
					<img src={selectedNetwork.img} alt="Ethereum"
						 width="20" />
					<span className="me-2 ms-2">{selectedNetwork.name}</span>
				</button>
				<ul className="dropdown-menu">
					<div className="ms-2">Select network</div>
					{
						CHAINS.map((chain) => (
							<li onClick={() => handleNetworkChange(chain)}><a
								className="dropdown-item"
								href="#">
								<img
									src={chain.img}
									alt="Ethereum"
									width="20" />
								<span className="ms-2">{chain.name}</span>
							</a></li>
						))
					}
				</ul>
			</div>
			<div onClick={openModalCallback}
				 className="d-flex align-items-center bg-gray rounded-pill  me-2 p-1 c-pointer">
				<div className="me-3 ms-3 fw-light fs-13">
					{balance.toFixed(5)} ETH
				</div>
				<div className="me-2 rounded-pill bg-white ps-2 pe-2 pt-1 pb-1">
					{trimAddress(address)}
					<img src={walletInfo?.icon} alt="Wallet" width="18" height="18"
						 className="d-inline-block align-text-top ms-2 me-2" />
				</div>
				<div className="me-2 ms-2 fw-bold">
					<i className="bi bi-bell"></i>
				</div>
			</div>
		</div>
	);
}

export default WalletProfile;