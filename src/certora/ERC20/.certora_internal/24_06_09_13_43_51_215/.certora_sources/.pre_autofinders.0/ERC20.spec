
// The methods block below gives various declarations regarding solidity methods.
methods
{
    // When a function is not using the environment (e.g., `msg.sender`), it can be
    // declared as `envfree`
    function balanceOf(address) external returns (uint) envfree;
    function allowance(address,address) external returns(uint) envfree;
    function totalSupply() external returns (uint) envfree;
}


/** @title Transfer must move `amount` tokens from the caller's
 *  account to `recipient`
 */
// rule transferSpec(address recipient, uint amount) {

//     env e;
    
//     // `mathint` is a type that represents an integer of any size
//     mathint balance_sender_before = balanceOf(e.msg.sender);
//     mathint balance_recip_before = balanceOf(recipient);

//     transfer(e, recipient, amount);

//     mathint balance_sender_after = balanceOf(e.msg.sender);
//     mathint balance_recip_after = balanceOf(recipient);

//     // Operations on mathints can never overflow nor underflow
//     assert balance_sender_after == balance_sender_before - amount,
//         "transfer must decrease sender's balance by amount";

//     assert balance_recip_after == balance_recip_before + amount,
//         "transfer must increase recipient's balance by amount";
// }

/// @title Transfer must move `amount` tokens from the caller's account to `recipient`
rule transferSpec(address recipient, uint amount) {

    env e;
    
    // `mathint` is a type that represents an integer of any size
    mathint balance_sender_before = balanceOf(e.msg.sender);
    mathint balance_recip_before = balanceOf(recipient);

    transfer(e, recipient, amount);

    mathint balance_sender_after = balanceOf(e.msg.sender);
    mathint balance_recip_after = balanceOf(recipient);

    address sender = e.msg.sender;  // A convenient alias

    // Operations on mathints can never overflow or underflow. 
    assert recipient != sender => balance_sender_after == balance_sender_before - amount,
        "transfer must decrease sender's balance by amount";

    assert recipient != sender => balance_recip_after == balance_recip_before + amount,
        "transfer must increase recipient's balance by amount";
    
    assert recipient == sender => balance_sender_after == balance_sender_before,
        "transfer must not change sender's balancer when transferring to self";
}

/// @title Total supply after mint is at least the balance of the receiving account
// rule totalSupplyAfterMint(address account, uint256 amount) {
//     env e; 
    
//     mint(e, account, amount);
    
//     uint256 userBalanceAfter = balanceOf(account);
//     uint256 totalAfter = totalSupply();
    
//     // Verify that the total supply of the system is at least the current balance of the account.
//     assert totalAfter >=  userBalanceAfter, "total supply is less than a user's balance";
// }

/** @title Total supply after mint is at least the balance of the receiving account, with
 *  precondition.
 */
rule totalSupplyAfterMintWithPrecondition(address account, uint256 amount) {
    env e; 
    
    // Assume that in the current state before calling mint, the total supply of the 
    // system is at least the user balance.
    uint256 userBalanceBefore =  balanceOf(account);
    uint256 totalBefore = totalSupply();
    require totalBefore >= userBalanceBefore; 
    
    mint(e, account, amount);
    
    uint256 userBalanceAfter = balanceOf(account);
    uint256 totalAfter = totalSupply();
    
    // Verify that the total supply of the system is at least the current balance of the account.
    assert totalAfter >= userBalanceAfter, "total supply is less than a user's balance ";
}