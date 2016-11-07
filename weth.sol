pragma solidity ^0.4.4;

contract WETH {
    function totalSupply() constant returns (uint) {
        return this.balance;
    }

    //------------------------------------------------------
    // Balances and transfers
    //------------------------------------------------------

    mapping (address => uint)  public  balanceOf;

    event Transfer(
        address  indexed  spender,
        address  indexed  recipient,
        uint              value
    );

    function transfer(address recipient, uint value) returns (bool) {
        assert(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        balanceOf[recipient] += value;
        Transfer(msg.sender, recipient, value);
        return true;
    }

    function transferFrom(
        address owner, address recipient, uint value
    ) returns (bool) {
        assert(balanceOf[owner] >= value);
        assert(allowance[owner][msg.sender] >= value);
        allowance[owner][msg.sender] -= value;
        balanceOf[owner] -= value;
        balanceOf[recipient] += value;
        Transfer(owner, recipient, value);
        return true;
    }

    //------------------------------------------------------
    // Allowances and approvals
    //------------------------------------------------------

    mapping (address => mapping (address => uint))  public  allowance;

    event Approval(
        address  indexed  owner,
        address  indexed  spender,
        uint              value
    );

    function approve(address spender, uint value) returns (bool) {
        allowance[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
    }

    //------------------------------------------------------
    // Deposits and withdrawals
    //------------------------------------------------------

    event Deposit    (address indexed owner, uint value);
    event Withdrawal (address indexed owner, uint value);

    function deposit() payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    function withdraw(uint value) {
        assert(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        assert(msg.sender.call.value(value)());
        Withdrawal(msg.sender, value);
    }

    //------------------------------------------------------
    // Helper functions
    //------------------------------------------------------

    function assert(bool condition) internal {
        if (!condition) throw;
    }
}
