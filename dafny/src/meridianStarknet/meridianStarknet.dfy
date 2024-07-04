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

    // dividing by 200 yields 0.5%
    var PERCENT_DIVISOR: u256 := 200;
    var DECIMAL_PRECISION: u256 := 1000000000000000000;
    // 0.5%
    var BORROWING_FEE_FLOOR: u256 := DECIMAL_PRECISION / 1000 * 5;
    var SECONDS_IN_ONE_MINUTE: u256 := 60;
    var MINUTE_DECAY_FACTOR: u256 := 999037758833783000;
    // Minimum amount of net LUSD debt a trove must have
    var MIN_NET_DEBT: u256 := 180 * DECIMAL_PRECISION; // 1800e18
    // Amount of LUSD to be locked in gas pool on opening troves
    var LUSD_GAS_COMPENSATION: u256 := 20 * DECIMAL_PRECISION;
    var NICR_PRECISION: u256 := 100000000000000000000;
    // Minimum collateral ratio for individual troves
    var MCR: u256 := 1100000000000000000; // 110%

    // Critical system collateral ratio. If the system's total collateral ratio (TCR) falls below the CCR, Recovery Mode is triggered.
    var CCR: u256 := 1500000000000000000; // Critical Collateral Ratio - 150%

    var ICR: u256;
    var NICR: u256;

    var LUSDFee: u256;
    var baseRate: u256 := 3861623;
    var lastFeeOperationTime: u256 := 1699446177;
    var timestamp: u256 := 1699446329;
    var LUSDDebt: u256 := 4500000000000000000000;
    var totalLQTYStaked: u256 := 1526442822657515176232017;
    var F_LUSD: u256 := 1007002700833302;
    var lqtyStakingAddress: u256 := 0xfccd02f7a964de33032cb57746dc3b5f9319eab7;
    var totalCollateralSnapshot: u256 := 58163523172750566957;
    var totalStakesSnapshot: u256 := 58163523172750566957;
    var totalStakes: u256 := 90742150931992561217;

    // priceFeed.fetchPrice
    var price: u256 := 1879370866900000000000;

    // _checkRecoveryMode(price) - return TCR < CCR
        // _getTCR(price) - calculate and return the TCR
            // getEntireSystemColl - calculate and return the total ETH in the contract
            var activeColl: u256 := 90742150931992561217; // amount of ETH in the active pool
            var liquidatedColl: u256 := 0; // amount of ETH in the default pool
        var entireSystemColl: u256 := 90742150931992561217; // activeColl + liquidatedColl
            // getEntireSystemDebt - calculate and return the total LUSD in the contract
            var activeDebt: u256 := 90659917857159191124518; // amount of LUSD in the active pool
            var closedDebt: u256 := 0; // amount of LUSD in the default pool
        var entireSystemDebt: u256 := 90659917857159191124518; // activeDebt + closedDebt
            // LiquityMath._computeCR(entireSystemColl, entireSystemDebt, price) - calculate collateral ratio
            var newCollRatio: u256 := entireSystemColl * price / entireSystemDebt;
            // 90742150931992561217 * 1879370866900000000000 / 90659917857159191124518 = 1881075550168971649;
        var TCR: u256 := newCollRatio;        // Total Collateral Ratio
        assert TCR == 1881075550168971649;    
    var isRecoveryMode :bool := TCR < CCR;
    assert isRecoveryMode == false;

    //_requireValidMaxFeePercentage(maxFeePercentage, isRecoveryMode)
    assert maxFeePercentage >= BORROWING_FEE_FLOOR && maxFeePercentage <= DECIMAL_PRECISION;

    // _requireTroveisNotActive(troveManager, borrower)
    var status: u256 := 2;
    assert status != 1;

    // how much fee should be paid for taking LUSD
    // _triggerBorrowingFee(troveManager, lusdToken, LUSDAmount, maxFeePercentage)
        // decayBaseRateFromBorrowing - update the baseRate based on time elapsed since the last redemption or LUSD borrowing operation
            // _calcDecayedBaseRate
                // _minutesPassedSinceLastFeeOp - number of minutes that have passed since lastFeeOperationTime.
                // (block.timestamp - lastFeeOperationTime) / SECONDS_IN_ONE_MINUTE;
                var minutesPassed: u256 := 2; 
                // _decPow(MINUTE_DECAY_FACTOR, minutesPassed) - calculate the power of a decimal base raised to a given exponent
                // decayFactor = MINUTE_DECAY_FACTOR ^ minutesPassed
                var decayFactor: u256 := 998076443575627963;
            // baseRate * decayFactor / DECIMAL_PRECISION;
            var decayedBaseRate: u256 := baseRate * decayFactor / DECIMAL_PRECISION; 
            assert decayedBaseRate == 3854194;
            assert decayedBaseRate <= DECIMAL_PRECISION;
        baseRate := decayedBaseRate;
        // _updateLastFeeOpTime() - Update lastFeeOperationTime only if time passed >= decay interval
        var timePassed: u256 := timestamp - lastFeeOperationTime;
        assert timePassed == 152;
        assert timePassed >= SECONDS_IN_ONE_MINUTE;
        lastFeeOperationTime := timestamp;
        // getBorrowingFee(LUSDAmount)
            // getBorrowingRate()
                // _calcBorrowingRate(baseRate)
                // min(BORROWING_FEE_FLOOR + baseRate, MAX_BORROWING_FEE)
                var borrowingRate: u256 := 5000000003854194;
            // _calcBorrowingFee(borrowingRate, LUSDDebt)
            // 5000000003854194 * 4500000000000000000000 / 5000000000000000
            var fee: u256 := borrowingRate * LUSDDebt / DECIMAL_PRECISION; 
            assert fee == 22500000017343873000;
        // _requireUserAcceptsFee(LUSDFee, LUSDAmount, maxFeePercentage)
        var feePercentage: u256 := fee * DECIMAL_PRECISION / LUSDAmount;
        assert feePercentage <= maxFeePercentage;
        // Send fee to LQTY staking contract
        // increaseF_LUSD(LUSDFee)
            // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
        assert totalLQTYStaked > 0;
        // LUSDFeePerLQTYStaked = 22500000017343873000 * 1000000000000000000 / 1526442822657515176232017
        var LUSDFeePerLQTYStaked: u256 := fee * DECIMAL_PRECISION / totalLQTYStaked;
        assert LUSDFeePerLQTYStaked == 14740152518894;
        F_LUSD := F_LUSD + LUSDFeePerLQTYStaked;
        assert F_LUSD == 1021742853352196;
        // mint(lqtyStakingAddress, LUSDFee) - mint LUSDFee amount from LUSD token
    
    LUSDFee := fee;
    var netDebt:u256 := LUSDAmount;
    netDebt := netDebt + LUSDFee;
    assert netDebt == 4522500000017343873000;
    
    // _requireAtLeastMinNetDebt()
    assert netDebt >= MIN_NET_DEBT;
    
    // ICR is based on the composite debt, i.e. the requested LUSD amount + LUSD borrowing fee + LUSD gas comp.
    // _getCompositeDebt(netDebt)
    // Returns the composite debt (drawn debt + gas compensation) of a trove, for the purpose of ICR calculation
    var compositeDebt: u256 := netDebt + LUSD_GAS_COMPENSATION;
    assert compositeDebt == 4542500000017343873000;
    assert compositeDebt > 0;

    // _computeCR(msg.value, compositeDebt, price) - calculate collateral ratio
    var value: u256 := 4800000000000000000;
    newCollRatio := value * price / compositeDebt;
    // 4800000000000000000 * 1879370866900000000000 / 4542500000017343873000 = 1985906474647343244;
    ICR := newCollRatio;
    assert ICR == 1985906474647343244;
    
    // _computeNominalCR(msg.value, compositeDebt)
    NICR := value * NICR_PRECISION / compositeDebt;
    assert NICR == 105668684644615805;

    // _requireICRisAboveMCR(ICR)
    assert ICR >= MCR;

    // _getNewTCRFromTroveChange(msg.value, true, compositeDebt, true, price) - bools: coll increase, debt increase
        // getEntireSystemColl - calculate and return the total ETH in the contract
        activeColl := 90742150931992561217; // amount of ETH in the active pool
        liquidatedColl := 0; // amount of ETH in the default pool
    var totalColl: u256 := 90742150931992561217; // activeColl + liquidatedColl
        // getEntireSystemDebt - calculate and return the total LUSD in the contract
        activeDebt := 90659917857159191124518; // amount of LUSD in the active pool
        closedDebt := 0; // amount of LUSD in the default pool
    var totalDebt: u256 := 90659917857159191124518; // activeDebt + closedDebt
    
    totalColl := totalColl + value;
    assert totalColl == 95542150931992561217;
    totalDebt := totalDebt + compositeDebt;
    assert totalDebt == 95202417857176534997518;

        // _computeCR(totalColl, totalDebt, price) - calculate collateral ratio
        newCollRatio := totalColl * price / totalDebt;
        // 95542150931992561217 * 1879370866900000000000 / 95202417857176534997518 = 188607746600000000;
        assert newCollRatio == 1886077465930808833;

    var newTCR: u256 := newCollRatio;

    // _requireNewTCRisAboveCCR(newTCR)
    assert newTCR >= CCR;

    // set the trove struct's properties

    // borrower = msg.sender
    var borrower: u160 := 0xca26ecf47ce060855e652a4179d1d461de943822;

    // setTroveStatus(msg.sender, 1)
        // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
    // Troves[borrower].status = Status(1)

    // increaseTroveColl(msg.sender, msg.value)
        // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
    // newColl = Troves[msg.sender].coll + msg.value
    var newColl: u256 := 0 + value;
    assert newColl == 4800000000000000000;
    // Troves[msg.sender].coll = newColl

    // increaseTroveDebt(msg.sender, compositeDebt)
        // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
        // newDebt = Troves[msg.sender].debt + compositeDebt
        var newDebt: u256 := 0 + compositeDebt;
    assert newDebt == 4542500000017343873000;
        // Troves[msg.sender].debt = newDebt

    // update borrower's snapshots of L_ETH and L_LUSDDebt to reflect the current values
    // updateTroveRewardSnapshots(msg.sender)
        // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
        // _updateTroveRewardSnapshots(msg.sender)
        // rewardSnapshots[msg.sender].ETH = L_ETH;
        // rewardSnapshots[msg.sender].LUSDDebt = L_LUSDDebt;

    // update borrower's stake based on their latest collateral value
    // updateStakeAndTotalStakes
        // _requireCallerIsBorrowerOperations - msg.sender == borrowerOperationsAddress
        // _updateStakeAndTotalStakes(msg.sender)
            // _computeNewStake(Troves[msg.sender].coll)
                // 4800000000000000000 * 58163523172750566957 / 58163523172750566957 = 4800000000000000000
                var stake: u256 := newColl * totalStakesSnapshot / totalCollateralSnapshot;
            var newStake: u256 := stake;
            assert newStake == 4800000000000000000;
            // oldStake = Troves[msg.sender].stake
            var oldStake: u256 := 0;
            //  Troves[msg.sender].stake = newStake
            totalStakes := totalStakes - oldStake + newStake;
        assert totalStakes == 95542150931992561217;

    // insert(msg.sender, NICR, upperHint, lowerHint)
        // _requireCallerIsBOorTroveM(troveManager) - msg.sender == borrowerOperationsAddress || msg.sender == troveManagerAddress
        // _insert(troveManager, msg.sender, NICR, upperHint, lowerHint)

}