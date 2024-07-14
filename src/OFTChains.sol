// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";

contract OFTChains is OFT {
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) Ownable(_delegate) {}


    // /**
    //  * @dev Burns tokens from the sender's specified balance. Only the owner can call this function.
    //  * @param _amountLD The amount of tokens to send in local decimals.
    //  * @param _minAmountLD The minimum amount to send in local decimals.
    //  * @param _dstEid The destination chain ID.
    //  * @return amountSentLD The amount sent in local decimals.
    //  * @return amountReceivedLD The amount received in local decimals on the remote.
    //  */
    // function _debit(
    //     uint256 _amountLD,
    //     uint256 _minAmountLD,
    //     uint32 _dstEid
    // ) internal virtual override onlyOwner returns (uint256 amountSentLD, uint256 amountReceivedLD) {
    //     (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);

    //     // @dev In NON-default OFT, amountSentLD could be 100, with a 10% fee, the amountReceivedLD amount is 90,
    //     // therefore amountSentLD CAN differ from amountReceivedLD.

    //     // @dev Default OFT burns on src.
    //     _burn(msg.sender, amountSentLD);
    // }
// function debit(
//     SendParam calldata _sendParam,
//     MessagingFee calldata _fee,
//     address _refundAddress
// ) public payable virtual returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) {
//     // @dev Applies the token transfers regarding this send() operation.
//     // - amountSentLD is the amount in local decimals that was ACTUALLY sent/debited from the sender.
//     // - amountReceivedLD is the amount in local decimals that will be received/credited to the recipient on the remote OFT instance.
//     (uint256 amountSentLD, uint256 amountReceivedLD) = _debit(
//         _sendParam.amountLD,
//         _sendParam.minAmountLD,
//         _sendParam.dstEid
//     );

//     // ...
// }

//     function credit(
//         address _to,
//         uint256 _amountToCreditLD,
//         uint32 srcEid
//     ) internal virtual override returns (uint256 amountReceivedLD) {

//     }

}