
fn inc(x: u32) -> u32 {
    return x + 1;
}

#[test]
fn test_inc() {
    let mut a = 4;
    a = inc(x: a);
    assert(a == 5, 'error');

    // same variable name
    let mut x = 4;
    x = inc(:x);
}