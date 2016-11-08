pragma solidity ^0.4.4;

contract WETH {
    function assert(bool condition) internal {
        if (!condition) throw;
    }

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    event Transfer(
        address  indexed  owner,
        address  indexed  recipient,
        uint              value
    );

    event Approval(
        address  indexed  owner,
        address  indexed  spender,
        uint              value
    );

    // Not ERC20
    event Deposit(
        address  indexed  owner,
        uint              value
    );
    
    // Not ERC20
    event Withdrawal(
        address  indexed  owner,
        uint              value
    );

    function totalSupply() constant returns (uint) {
        return this.balance;
    }

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

    function approve(address spender, uint value) returns (bool) {
        allowance[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
    }

    // Not ERC20
    function deposit() payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }

    // Not ERC20
    function withdraw(uint value) {
        assert(balanceOf[msg.sender] >= value);
        balanceOf[msg.sender] -= value;
        assert(msg.sender.send(value));
        Withdrawal(msg.sender, value);
    }
}
