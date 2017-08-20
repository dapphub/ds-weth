/// WETH.sol -- Wrap ETH into a contract

// Copyright 2016, 2017  Nexus Development, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// A copy of the License may be obtained at the following URL:
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.4.15;

contract WETH {

    mapping (address => mapping(address=>bool) ) deps;

    event Wrap(
        address indexed who,
        uint256         amt
    );

    event Unwrap(
        address indexed who,
        uint256         amt
    );

    event Move(
        address indexed src,
        address indexed dst,
        uint256 amt
    );

    event Rely(
        address indexed src,
        address indexed dst
    );
    event Deny(
        address indexed src,
        address indexed dst
    );




    //----------------------------------------------------------------
    // ERC20    sucks
    //----------------------------------------------------------------

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function totalSupply() constant returns (uint) {
        return this.balance;
    }


    function transfer(address recipient, uint256 value) returns (bool) {
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
}
