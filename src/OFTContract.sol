// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";

contract OFTContract is OFT {

    uint32 eid;

    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate,
        uint32 _eid
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(_delegate) {
        _mint(msg.sender, 100_000 ether);
        eid = _eid;
    }


    function  debit(uint256 _amountLD, uint256 _minAmountLD,uint32 _dstEid) public payable {
        _debit(_amountLD, _minAmountLD, _dstEid);
    }


    function credit(address _to, uint256 _amountLD) public payable{
        _credit(_to, _amountLD, eid);
    }
}