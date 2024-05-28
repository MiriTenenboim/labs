
include "util/number.dfy"
include "util/maps.dfy"
include "util/tx.dfy"
include "fixed.dfy"


import opened Number
import opened Maps
import opened Tx
import opened Fixed


class LendingProtocol {
    var totalBorrow: u256
    var totalReserve: u256
    var totalDeposit: u256
    const maxLTV: u256 := 4
    var ethTreasury: u256
    var totalCollateral: u256
    const baseRate: u256 := 20000000000000000
    const fixedAnnuBorrowRate: u256 := 300000000000000000

    var usersCollateral: mapping<u160, u256>
    var usersBorrowed: mapping<u160, u256>

    const WAD: u256 := 1000000000000000000

    constructor() {
        totalDeposit := 1000;
        totalBorrow := 20;

        usersCollateral := Map(map[], 0);
        usersBorrowed := Map(map[], 0);
    }

    method utilizationRatio() returns (utilizationRatio: u256)
    // ensures utilizationRatio == this.totalBorrow / this.totalDeposit
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * (this.fixedAnnuBorrowRate - this.baseRate) as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        // var num: u256 := Sub(this.fixedAnnuBorrowRate, this.baseRate);
        // var mul: u256 := Mul(this.totalBorrow, num);
        // utilizationRatio := Fixed.Div(mul, this.totalDeposit);

        var num: u256 := this.fixedAnnuBorrowRate - this.baseRate;
        var mul: u256 := this.totalBorrow * num;
        utilizationRatio := mul / this.totalDeposit;
    }

    method interestMultiplier() returns (interestMul: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * (this.fixedAnnuBorrowRate - this.baseRate) as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var uRatio: u256 := utilizationRatio();
        var num: u256 := this.fixedAnnuBorrowRate - this.baseRate;
        if uRatio == 0 {
            interestMul := 0;
        }
        else {
            interestMul := num / uRatio;
        }
    }
    

    method borrowRate() returns (rate: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * (this.fixedAnnuBorrowRate - this.baseRate) as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    ensures rate as nat <= MAX_U256 as nat
    {
        var uRatio: u256 := utilizationRatio();
        var interestMul: u256 := interestMultiplier();
        var product:u256 :=0;
        if uRatio as nat * interestMul as nat <= MAX_U256 as nat {
            product := uRatio * interestMul;
        }
        rate := 0;
        if product as nat + baseRate as nat <= MAX_U256 as nat {
            rate := product + baseRate;
        }
    }

    method calculateBorrowFee(amount: u256) returns (fee: u256, paid: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * (this.fixedAnnuBorrowRate - this.baseRate) as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var borrowRate: u256 := borrowRate();
        fee := 0;
        if amount as nat * borrowRate as nat <= MAX_U256 as nat {
            // fee := amount * borrowRate;
            fee := Mul(amount, borrowRate);
        }
        paid := 0;
        if amount as nat - fee as nat > 0 as nat {
            paid := amount - fee;
        }
    }
}