include "../util/number.dfy"
include "../util/maps.dfy"
include "../util/tx.dfy"
include "../util/fixed.dfy"

import opened Number
import opened Maps
import opened Tx
import opened Fixed


method {:test} MeridianStaknet() {
    var fromAddress: u160 := 0x00bd3ba46d5a8b0f397d92e80fd054b24b8636c5;
    var fromBalance: u256 := 4500000000000000000;
   
    var toAddress: u160 := 0x18c9712c38d7ac0cf7de744bf9f82c46eada33ae;
    var toBalance: u256 := 0;


    // openTrove(maxFeePercentage, LUSDAmount, upperHint, lowerHint)

    var maxFeePercentage: u256 := 10000000003854194;
    var LUSDAmount: u256 := 4500000000000000000000;
    var upperHint: u160 := 0x8a42FB39899f14514a7F2694bD39EF84784F1d5d;
    var lowerHint: u160 := 0x68Df65D9a8fa31F36A662175Bb44507aDb700932;

    var PERCENT_DIVISOR: u256 := 200;
    var DECIMAL_PRECISION: u256 := 1000000000000000000;
    var BORROWING_FEE_FLOOR: u256 := DECIMAL_PRECISION / 1000 * 5;
    var SECONDS_IN_ONE_MINUTE: u256 := 60;

    var LUSDFee: u256;
    var baseRate: u256;
    var lastFeeOperationTime: u256;

    // priceFeed.fetchPrice
    var price: u256 := 1879370866900000000000;

    // _checkRecoveryMode(price)
        // _getTCR(price)
            // getEntireSystemColl
            var activeColl: u256 := 90742150931992561217; // amount of ETH in the active pool
            var liquidatedColl: u256 := 0; // amount of ETH in the default pool
        var entireSystemColl: u256 := 90742150931992561217; // activeColl + liquidatedColl
            // getEntireSystemDebt
            var activeDebt: u256 := 90659917857159191124518; // amount of LUSD in the active pool
            var closedDebt: u256 := 0; // amount of LUSD in the default pool
        var entireSystemDebt: u256 := 90659917857159191124518; // activeDebt + closedDebt
            // LiquityMath._computeCR(entireSystemColl, entireSystemDebt, price)
            var newCollRatio: u256 := entireSystemColl * price / entireSystemDebt;
            // 90742150931992561217 * 1879370866900000000000 / 90659917857159191124518 = 1881075550168971649;
        var TCR: u256 := newCollRatio;        // Total Collateral Ratio
        assert TCR == 1881075550168971649;    
        var CCR: u256 := 1500000000000000000; // Critical Collateral Ratio
    var isRecoveryMode :bool := TCR < CCR;
    assert isRecoveryMode == false;

    //_requireValidMaxFeePercentage(maxFeePercentage, isRecoveryMode)
    assert maxFeePercentage >= BORROWING_FEE_FLOOR && maxFeePercentage <= DECIMAL_PRECISION;

    // _requireTroveisNotActive(troveManager, borrower)
    var status: u256 := 2;
    assert status != 1;

    // _triggerBorrowingFee(troveManager, lusdToken, LUSDAmount, maxFeePercentage)
        // decayBaseRateFromBorrowing
            // _calcDecayedBaseRate
                // _minutesPassedSinceLastFeeOp
                // (block.timestamp - lastFeeOperationTime) / SECONDS_IN_ONE_MINUTE;
            var minutesPassed: u256 := 2; // number of minutes that have passed since lastFeeOperationTime.
                // _decPow
            var decayFactor: u256 := 998076443575627963;
        var decayedBaseRate: u256 := 3854194; 
        assert decayedBaseRate <= DECIMAL_PRECISION;
        baseRate := decayedBaseRate;
        // _updateLastFeeOpTime
            var timePassed: u256 := 152;
            assert timePassed >= SECONDS_IN_ONE_MINUTE;
            // lastFeeOperationTime := 
        // getBorrowingFee
            // getBorrowingRate
                // _calcBorrowingRate
                var borrowingRate: u256 := 5000000003854194;
            // _calcBorrowingFee(LUSDAmount)
            var fee: u256 := borrowingRate * LUSDAmount; // 5000000003854194 * 4500000000000000000000
            fee := fee / DECIMAL_PRECISION;
            assert fee == 22500000017343873000;
    LUSDFee := fee;
        // _requireUserAcceptsFee(LUSDFee, LUSDAmount, maxFeePercentage)
        var feePercentage: u256 := LUSDFee * DECIMAL_PRECISION / LUSDAmount;
        assert feePercentage <= maxFeePercentage;
}