
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
    var maxLTV: u256
    var ethTreasury: u256
    var totalCollateral: u256
    var baseRate: u256
    var fixedAnnuBorrowRate: u256

    var usersCollateral: mapping<u160, u256>
    var usersBorrowed: mapping<u160, u256>

    var WAD: u256

    constructor() {
        maxLTV := 4;
        baseRate := 20000000000000000;
        fixedAnnuBorrowRate := 300000000000000000;

        WAD := 1000000000000000000;

        usersCollateral := Map(map[], 0);
        usersBorrowed := Map(map[], 0);
    }

    method utilizationRatio() returns (utilizationRatio: u256)
    ensures utilizationRatio == this.totalBorrow / this.totalDeposit
    {
        utilizationRatio := Fixed.Div(this.totalBorrow, this.totalDeposit);
    }

    method interestMultiplier() returns (interestMultiplier: u256)
    {
        var uRatio: u256 := utilizationRatio();
        var num: u256 := Sub(this.fixedAnnuBorrowRate, this.baseRate);
        interestMultiplier := Fixed.Div(num, uRatio);
    }
    

    method borrowRate() returns (rate: u256)
    requires rate > 0 {
        var uRatio: u256 := utilizationRatio();

    }


    method calculateBorrowFee(amount: u256) returns (fee: u256, paid: u256)
    requires amount > 0

    {
        totalDeposit := totalDeposit;
        return Ok(());
    }
}