/*
   Copyright 2016 Nexus Development, LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

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
        return true;
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
