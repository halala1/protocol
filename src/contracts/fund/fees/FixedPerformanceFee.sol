pragma solidity ^0.4.21;

import "./Fee.i.sol";
import "./FeeManager.sol";
import "../accounting/Accounting.sol";
import "../hub/Hub.sol";
import "../shares/Shares.sol";
import "../../dependencies/math.sol";

contract FixedPerformanceFee is DSMath, Fee {

    uint public PERFORMANCE_FEE_RATE = 10 ** 16; // 0.01*10^18, or 1%
    uint public DIVISOR = 10 ** 18;

    mapping(address => uint) public highWaterMark;
    mapping(address => uint) public lastPayoutTime;

    function feeAmount() public view returns (uint feeInShares) {
        Hub hub = FeeManager(msg.sender).hub();
        Accounting accounting = Accounting(hub.accounting());
        Shares shares = Shares(hub.shares());
        uint currentSharePrice = accounting.calcSharePrice();
        if (currentSharePrice > highWaterMark[msg.sender]) {
            uint gav = accounting.calcGav();
            if (gav == 0) {
                feeInShares = 0;
            } else {
                uint sharePriceGain = sub(currentSharePrice, highWaterMark[msg.sender]);
                uint totalGain = mul(sharePriceGain, shares.totalSupply()) / DIVISOR;
                uint feeInAsset = mul(totalGain, PERFORMANCE_FEE_RATE) / DIVISOR;
                feeInShares = mul(shares.totalSupply(), feeInAsset) / gav;
            }
        } else {
            feeInShares = 0;
        }
        return feeInShares;
    }

    // TODO: avoid replication of variables between this and feeAmount
    // TODO: avoid running everything twice when calculating & claiming fees
    function updateState() external {
        if (feeAmount() > 0) {
            Accounting accounting = Accounting(Hub(FeeManager(msg.sender).hub()).accounting());
            lastPayoutTime[msg.sender] = block.timestamp;
            highWaterMark[msg.sender] = accounting.calcSharePrice();
        }
    }
}

