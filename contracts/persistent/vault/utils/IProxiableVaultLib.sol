// SPDX-License-Identifier: GPL-3.0

/*
    This file is part of the Enzyme Protocol.

    (c) Enzyme Council <council@enzyme.finance>

    For the full license information, please view the LICENSE
    file that was distributed with this source code.
*/

pragma solidity >=0.6.0 <0.9.0;

/// @title IProxiableVaultLib interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Interface for ProxiableVaultLib
interface IProxiableVaultLib {
    function proxiableUUID() external pure returns (bytes32 uuid_);
}
