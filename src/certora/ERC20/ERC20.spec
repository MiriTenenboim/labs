
methods
{
    function balanceOf(address) external returns (uint) envfree;
    function allowance(address,address) external returns(uint) envfree;
    function totalSupply() external returns (uint) envfree;
}


// rule transferSpec(address recipient, uint amount) {

//     env e;
    
//     mathint balance_sender_before = balanceOf(e.msg.sender);
//     mathint balance_recip_before = balanceOf(recipient);

//     transfer(e, recipient, amount);

//     mathint balance_sender_after = balanceOf(e.msg.sender);
//     mathint balance_recip_after = balanceOf(recipient);

//     assert balance_sender_after == balance_sender_before - amount,
//         "transfer must decrease sender's balance by amount";

//     assert balance_recip_after == balance_recip_before + amount,
//         "transfer must increase recipient's balance by amount";
// }


rule transferSpec(address recipient, uint amount) {

    env e;
    
    mathint balance_sender_before = balanceOf(e.msg.sender);
    mathint balance_recip_before = balanceOf(recipient);

    transfer(e, recipient, amount);

    mathint balance_sender_after = balanceOf(e.msg.sender);
    mathint balance_recip_after = balanceOf(recipient);

    address sender = e.msg.sender;

    assert recipient != sender => balance_sender_after == balance_sender_before - amount,
        "transfer must decrease sender's balance by amount";

    assert recipient != sender => balance_recip_after == balance_recip_before + amount,
        "transfer must increase recipient's balance by amount";
    
    assert recipient == sender => balance_sender_after == balance_sender_before,
        "transfer must not change sender's balancer when transferring to self";
}

// rule totalSupplyAfterMint(address account, uint256 amount) {
//     env e; 
    
//     mint(e, account, amount);
    
//     uint256 userBalanceAfter = balanceOf(account);
//     uint256 totalAfter = totalSupply();
    
//     assert totalAfter >=  userBalanceAfter, "total supply is less than a user's balance";
// }


rule totalSupplyAfterMintWithPrecondition(address account, uint256 amount) {
    env e; 
    
    uint256 userBalanceBefore =  balanceOf(account);
    uint256 totalBefore = totalSupply();
    require totalBefore >= userBalanceBefore; 
    
    mint(e, account, amount);
    
    uint256 userBalanceAfter = balanceOf(account);
    uint256 totalAfter = totalSupply();
    
    assert totalAfter >= userBalanceAfter, "total supply is less than a user's balance ";
}