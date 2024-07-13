import { BrowserProvider, Contract } from "ethers";
import Project from "./abi/Abi.json";

export const CONTRACT_ADDRESS = '0xd67014402237f75DEB3EaF3e9cda0C34F65cA684';

export const GET_CONTRACT = async (walletProvider: any): Promise<Contract> => {
	const provider = new BrowserProvider(walletProvider);
	const signer = await provider.getSigner();
	return new Contract(CONTRACT_ADDRESS, Project, signer);
};
