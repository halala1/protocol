// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Foundation <security@enzyme.finance>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

import {IExternalPosition} from "../../IExternalPosition.sol";

pragma solidity >=0.6.0 <0.9.0;
pragma experimental ABIEncoderV2;

/// @title ISolvV2BondIssuerPosition Interface
/// @author Enzyme Foundation <security@enzyme.finance>
interface ISolvV2BondIssuerPosition is IExternalPosition {
    enum Actions {
        CreateOffer,
        Reconcile,
        Refund,
        RemoveOffer,
        Withdraw
    }

    function getOffers() external view returns (uint24[] memory offers_);
}
