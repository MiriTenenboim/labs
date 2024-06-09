use debug::PrintTrait;

fn main() {
    let x: felt252 = 3618502788666131213697322783095070105623107215331596699973092056135872020479;
    let y: felt252 = 1;

    let mut a = x + 2;
    a = a / 2;
    a.print();

    assert(x + y == 0, 'P == 0 (mod P)');

    assert(x + 1 == 3618502788666131213697322783095070105623107215331596699973092056135872020480, '(P - 1) + 1 == 0 (mod P)');

    assert(x + 1 == 0, '(P - 1) + 1 == 0 (mod P)');
    
    assert(x == 0 - 1, 'subtraction is modular');

    assert(x * x == 1, 'multiplication is modular');
}