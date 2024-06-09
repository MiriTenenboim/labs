use debug::PrintTrait;

fn main() {
    let immutable_var: felt252 = 17;

    let mut mutable_var: felt252 = immutable_var;
    mutable_var = 38;

    mutable_var.print();
    immutable_var.print();

    assert(mutable_var != immutable_var, 'mutable equal immutable');
}

#[test]
fn test_main() {
    main();
}