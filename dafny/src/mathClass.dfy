include "util/number.dfy"
include "util/maps.dfy"
include "util/tx.dfy"

import opened Number
import opened Maps
import opened Tx

class MathClass {
    const EXP_SCALE: nat := Pow(10, 18)
    const HALF_EXP_SCALE: nat := EXP_SCALE / 2  
    

    method getExp(num: nat, denom: nat) returns (rational: nat)
        requires denom > 0
        ensures rational == if num * EXP_SCALE % denom == 0 then num * EXP_SCALE / denom else 0
    {
        var scaledNumber := num * EXP_SCALE;
        var remainder := scaledNumber % denom;
        if remainder == 0 {
            rational := scaledNumber / denom;
        } else {
            rational := 0;
        }
    }

    method mulExp(a: u256, b: u256) returns ()
}
