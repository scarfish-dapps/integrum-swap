import { BrowserProvider, Contract } from "ethers";
import Project from "./abi/Abi.json";

export const CONTRACT_ADDRESS = '0x1BaABb8eDDDCcf88a3bAF96b04a4267708Eb0D00';

export const GET_CONTRACT = async (walletProvider: any): Promise<Contract> => {
	const provider = new BrowserProvider(walletProvider);
	const signer = await provider.getSigner();
	return new Contract(CONTRACT_ADDRESS, Project, signer);
};
