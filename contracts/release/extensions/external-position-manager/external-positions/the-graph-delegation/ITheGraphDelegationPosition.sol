// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.
    (c) Enzyme Council <council@enzyme.finance>
    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

import {IExternalPosition} from "../../../../../persistent/external-positions/IExternalPosition.sol";

pragma solidity >=0.6.0 <0.9.0;

/// @title ITheGraphDelegationPosition Interface
/// @author Enzyme Council <security@enzyme.finance>
interface ITheGraphDelegationPosition is IExternalPosition {
    enum Actions {
        Delegate,
        Undelegate,
        Withdraw
    }
}
