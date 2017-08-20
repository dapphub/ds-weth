pragma solidity ^0.4.10;

import 'ds-token/base.sol';
import 'ds-exec/exec.sol';

contract DSEthTokenEvents {
    event Deposit(address indexed who, uint amount);
    event Withdrawal(address indexed who, uint amount);
}

contract DSEthToken is DSTokenBase(0)
                     , DSExec
                     , DSEthTokenEvents
{
    string public constant name     = "Wrapped ETH";
    string public constant symbol   = "W-ETH";
    uint   public constant decimals = 18;

    function withdraw(uint amount) {
        assert(tryWithdraw(amount));
    }

    function tryWithdraw(uint amount) returns (bool ok) {
        _balances[msg.sender] = sub(_balances[msg.sender], amount);
        _supply = sub(_supply, amount);
        if (tryExec(msg.sender, amount)) {
            Withdrawal(msg.sender, amount);
            return true;
        } else {
            _balances[msg.sender] = add(_balances[msg.sender], amount);
            _supply = add(_supply, amount);
            return false;
        }
    }
    
    function deposit() payable {
        _balances[msg.sender] = add(_balances[msg.sender], msg.value);
        _supply = add(_supply, msg.value);
        Deposit(msg.sender, msg.value);
    }

    function() payable {
        deposit();
    }

    function unwrap(uint amount) {
        withdraw(amount);
    }

    function wrap() payable {
        deposit();
    }
}
