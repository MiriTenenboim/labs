
include "util/number.dfy"
include "util/maps.dfy"
include "util/tx.dfy"


import opened Number
import opened Maps
import opened Tx


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

    constructor() {
        maxLTV := 4;
        baseRate := 20000000000000000;
        fixedAnnuBorrowRate := 300000000000000000;

        usersCollateral := Map(map[], 0);
        usersBorrowed := Map(map[], 0);
    }

    method bondAsset(msg: Transaction) returns (r: Result<()>)
    modifies this`totalDeposit {
        totalDeposit := totalDeposit;
        return Ok(());
    }
}