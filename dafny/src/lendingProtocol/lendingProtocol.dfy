include "../util/number.dfy"
include "../util/maps.dfy"
include "../util/tx.dfy"
include "../util/fixed.dfy"
include "../erc20.dfy"


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
    var usersBorrowed: mapping<u160, u256>    // DAI - borrow
    var usersBalances: mapping<u160, u256>    // DAI - bond

    const WAD: u256 := 1000000000000000000
    const HALF_WAD: u256 := WAD / 2

    var DAI: ERC20
    var bDAI: ERC20

    constructor() {
        usersCollateral := Map(map[], 0);
        usersBorrowed := Map(map[], 0);
        usersBalances := Map(map[], 0);

        DAI := new ERC20();
        bDAI := new ERC20();
    }

    method getCash() returns (cash: u256)
    requires this.totalDeposit as nat - this.totalBorrow as nat >= 0 as nat
    {
        cash := Sub(this.totalDeposit, this.totalBorrow);
    }

    method bondAsset(msg: Transaction, amount: u256)
    modifies this`totalDeposit
    modifies this`usersBalances
    requires usersBalances.Get(msg.sender) as nat + amount as nat <= MAX_U256 as nat
    requires this.totalDeposit as nat + amount as nat <= MAX_U256 as nat {
        usersBalances := usersBalances.Set(msg.sender, usersBalances.Get(msg.sender) + amount);
        // var bondToMint: u256 := getExp(amount, )
        totalDeposit := totalDeposit + amount;
    }
    

    method addCollateral(msg: Transaction, amount: u256) returns (r: Result<()>)
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

    method getExp(x: u256, y: u256) returns (result: u256)
    requires x as nat * WAD as nat <= MAX_U256 as nat
    requires y != 0
    {
        var mul: u256 := Mul(x, WAD);
        result := Fixed.Div(mul, y);
    }

    method mulExp(x: u256, y: u256) returns (result: u256)
    requires x as nat * y as nat <= MAX_U256 as nat
    {
        var mul: u256 := Mul(x, y);
        assume {:axiom} (HALF_WAD as nat) + (mul as nat) <= MAX_U256 as nat;
        var add: u256 := Add(HALF_WAD, mul);
        result := Fixed.Div(add, WAD);
    }

    method utilizationRatio() returns (utilizationRatio: u256)
    requires this.totalBorrow as nat * this.totalDeposit as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    requires (this.totalBorrow as nat) * (WAD as nat) <= MAX_U256 as nat
    requires Mul(this.totalBorrow, WAD) as nat + (this.totalDeposit / 2) as nat <= MAX_U256
    {
        utilizationRatio := Wdiv(this.totalBorrow, this.totalDeposit);
    }

    method interestMultiplier() returns (interestMul: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    requires this.totalBorrow as nat * this.totalDeposit as nat <= MAX_U256 as nat
    requires Mul(this.totalBorrow, WAD) as nat + (this.totalDeposit / 2) as nat <= MAX_U256
    {
        var uRatio: u256 := utilizationRatio();
        var num: u256 := Sub(this.fixedAnnuBorrowRate, this.baseRate);
        assume {:axiom} (uRatio as nat) > 0 as nat;
        interestMul := getExp(num, uRatio);
    }
    

    method borrowRate() returns (rate: u256)
    requires this.fixedAnnuBorrowRate > this.baseRate
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    requires this.totalBorrow as nat * this.totalDeposit as nat <= MAX_U256 as nat
    requires Mul(this.totalBorrow, WAD) as nat + (this.totalDeposit / 2) as nat <= MAX_U256
    {
        var uRatio: u256 := utilizationRatio();
        var interestMul: u256 := interestMultiplier();
        assume {:axiom} (uRatio as nat) * (interestMul as nat) <= MAX_U256 as nat;
        var product := mulExp(uRatio, interestMul);
        assume {:axiom} (product as nat) + (baseRate as nat) <= MAX_U256 as nat;
        rate := Add(product, baseRate);
    }

    // method calculateBorrowFee(amount: u256) returns (fee: u256, paid: u256)
    method calculateBorrowFee(amount: u256) returns (paid: u256)
    requires this.totalBorrow as nat * WAD as nat <= MAX_U256 as nat
    requires this.totalDeposit != 0
    requires this.totalBorrow as nat * this.totalDeposit as nat <= MAX_U256 as nat
    requires Mul(this.totalBorrow, WAD) as nat + (this.totalDeposit / 2) as nat <= MAX_U256
    {
        var borrowRate: u256 := borrowRate();
        assume {:axiom} (amount as nat) * (borrowRate as nat) <= MAX_U256 as nat;
        var fee: u256 := mulExp(amount, borrowRate);
        assume {:axiom} (amount as nat) - (fee as nat) >= 0 as nat;
        paid := Sub(amount, fee);
    }
}


// --- TESTS

import opened Fixed
import opened Number
import opened Maps
import opened Tx

method {:test} testLendingProtocol() {
    // Instantiate the LendingProtocol class
    var protocol := new LendingProtocol();

    // Set necessary values for totalDeposit and totalBorrow using setter methods
    protocol.totalDeposit := 100; // Setting totalDeposit to 1 ether (for example)
    protocol.totalBorrow := 50;   // Setting totalBorrow to 0.5 ether (for example)

    assert protocol.totalDeposit == 100;
    assert protocol.totalBorrow == 50;

    // Define the amount for which the borrow fee needs to be calculated
    var borrowAmount: u256 := 20; // Example borrow amount

    // Declare variables to store the results
    var fee: u256;
    var paid: u256;

    // Call the calculateBorrowFee method and store the results
    // paid := protocol.calculateBorrowFee(borrowAmount);

    var uRa: u256 := Wdiv(protocol.totalBorrow, protocol.totalDeposit);
    assert uRa == 500000000000000000;

    var a: u256 := protocol.utilizationRatio();
    // assert a == 500000000000000000;

    // assert paid == 14;

    // Print or assert the results to verify correctness
    // print "Borrow Fee: ", fee, "\n";
    // print "Amount Paid: ", paid, "\n";

    // Optionally, you can include assertions to check expected values
    // assert fee >= 0;
    // assert paid == borrowAmount - fee;
}


