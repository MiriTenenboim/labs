
include "util/number.dfy"
include "util/maps.dfy"
include "util/tx.dfy"
include "fixed.dfy"
include "erc20.dfy"


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

    var usersCollateral: mapping<u160, u256>  // ETH
    var usersBorrowed: mapping<u160, u256>    // DAI
    var usersBalances: mapping<u160, u256>    // DAI

    const WAD: u256 := 1000000000000000000

    var DAI: ERC20
    var bDAI: ERC20

    constructor() {
        usersCollateral := Map(map[], 0);
        usersBorrowed := Map(map[], 0);
        usersBalances := Map(map[], 0);

        DAI := new ERC20();
        bDAI := new ERC20();
    }

    method bondAsset(msg: Transaction, amount: u256)
    modifies this`totalDeposit
    requires this.totalDeposit as nat + amount as nat <= MAX_U256 as nat {
        // usersBalances := 
        totalDeposit := totalDeposit + amount;
    }
    

    method supply(msg: Transaction, amount: u256) returns (r: Result<()>)
    modifies this`usersCollateral
    requires amount as nat <= MAX_U256 - usersCollateral.Get(msg.sender) as nat {
        usersCollateral := usersBalances.Set(msg.sender, usersCollateral.Get(msg.sender) + amount);
        return Ok(());
    }

    method removeCollateral(msg: Transaction, amount: u256) returns (r: Result<()>)
    modifies this`usersCollateral
    requires amount as nat <= usersCollateral.Get(msg.sender) as nat {
        usersCollateral := usersBalances.Set(msg.sender, usersCollateral.Get(msg.sender) - amount);
        return Ok(());
    }

    method utilizationRatio() returns (utilizationRatio: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var mul: u256 := Mul(this.totalBorrow, WAD);
        utilizationRatio := Fixed.Div(mul, this.totalDeposit);
    }

    method interestMultiplier() returns (interestMul: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var uRatio: u256 := utilizationRatio();
        var num: u256 := Sub(this.fixedAnnuBorrowRate, this.baseRate);
        if uRatio == 0 {
            interestMul := 0;
        }
        else {
            interestMul := Fixed.Div(num, uRatio);
        }
    }
    

    method borrowRate() returns (rate: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var uRatio: u256 := utilizationRatio();
        var interestMul: u256 := interestMultiplier();
        var product:u256 :=0;
        if uRatio as nat * interestMul as nat <= MAX_U256 as nat {
            product := Mul(uRatio, interestMul);
        }
        rate := 0;
        if product as nat + baseRate as nat <= MAX_U256 as nat {
            rate := Add(product, baseRate);
        }
    }

    method calculateBorrowFee(amount: u256) returns (fee: u256, paid: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    {
        var borrowRate: u256 := borrowRate();
        fee := 0;
        if amount as nat * borrowRate as nat <= MAX_U256 as nat {
            fee := Mul(amount, borrowRate);
        }
        paid := 0;
        if amount as nat - fee as nat > 0 as nat {
            paid := Sub(amount, fee);
        }
    }
}