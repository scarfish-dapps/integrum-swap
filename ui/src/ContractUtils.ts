import { BrowserProvider, Contract } from "ethers";
import Project from "./abi/Abi.json";

export const CONTRACT_ADDRESS = '0xE3Ce703C188cC192e963E4CdC96083F388adC213';

export const GET_CONTRACT = async (walletProvider: any): Promise<Contract> => {
	const provider = new BrowserProvider(walletProvider);
	const signer = await provider.getSigner();
	return new Contract(CONTRACT_ADDRESS, Project, signer);
};
