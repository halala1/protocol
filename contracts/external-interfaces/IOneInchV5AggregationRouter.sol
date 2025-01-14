// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Foundation <security@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title IOneInchV5AggregationRouter Interface
/// @author Enzyme Foundation <security@enzyme.finance>
interface IOneInchV5AggregationRouter {
    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }

    function swap(address _executor, SwapDescription calldata _desc, bytes calldata _permit, bytes calldata _data)
        external
        payable
        returns (uint256 returnAmount_, uint256 spentAmount_);
}
