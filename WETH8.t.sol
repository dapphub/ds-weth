/// WETH8.t.sol -- tests for WETH8

// Copyright 2016  Nexus Development, LLC
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

pragma solidity ^0.4.4;

import "dapple/test.sol";

import "WETH8.sol";

contract WETH8Test is Test, WETH8Events {
    WETH8   weth   = new WETH8();
    Person  alice  = new Person(weth);
    Person  bob    = new Person(weth);
    Person  carol  = new Person(weth);

    function test_initial_state() {
        assert_eth_balance   (alice, 0 finney);
        assert_weth_balance  (alice, 0 finney);
        assert_eth_balance   (bob,   0 finney);
        assert_weth_balance  (bob,   0 finney);
        assert_eth_balance   (carol, 0 finney);
        assert_weth_balance  (carol, 0 finney);

        assert_weth_supply   (0 finney);
    }

    function test_deposit() {
        expectEventsExact    (weth);

        perform_deposit      (alice,  3 finney);
        assert_weth_balance  (alice,  3 finney);
        assert_weth_balance  (bob,    0 finney);
        assert_eth_balance   (alice,  0 finney);
        assert_weth_supply   (3 finney);

        perform_deposit      (alice,  4 finney);
        assert_weth_balance  (alice,  7 finney);
        assert_weth_balance  (bob,    0 finney);
        assert_eth_balance   (alice,  0 finney);
        assert_weth_supply   (7 finney);

        perform_deposit      (bob,    5 finney);
        assert_weth_balance  (bob,    5 finney);
        assert_weth_balance  (alice,  7 finney);
        assert_weth_supply   (12 finney);
    }

    function testFail_withdrawal_1() {
        perform_withdrawal   (alice,  1 wei);
    }

    function testFail_withdrawal_2() {
        perform_deposit      (alice,  1 finney);
        perform_withdrawal   (bob,    1 wei);
    }

    function testFail_withdrawal_3() {
        perform_deposit      (alice,  1 finney);
        perform_deposit      (bob,    1 finney);
        perform_withdrawal   (bob,    1 finney);
        perform_withdrawal   (bob,    1 wei);
    }

    function test_withdrawal() {
        expectEventsExact    (weth);

        perform_deposit      (alice,  7 finney);
        assert_weth_balance  (alice,  7 finney);
        assert_eth_balance   (alice,  0 finney);

        perform_withdrawal   (alice,  3 finney);
        assert_weth_balance  (alice,  4 finney);
        assert_eth_balance   (alice,  3 finney);

        perform_withdrawal   (alice,  4 finney);
        assert_weth_balance  (alice,  0 finney);
        assert_eth_balance   (alice,  7 finney);
    }

    function testFail_transfer_1() {
        perform_transfer     (alice,  1 wei, bob);
    }

    function testFail_transfer_2() {
        perform_deposit      (alice,  1 finney);
        perform_withdrawal   (alice,  1 finney);
        perform_transfer     (alice,  1 wei, bob);
    }

    function test_transfer() {
        expectEventsExact    (weth);

        perform_deposit      (alice,  7 finney);
        perform_transfer     (alice,  3 finney, bob);
        assert_weth_balance  (alice,  4 finney);
        assert_weth_balance  (bob,    3 finney);
        assert_weth_supply   (7 finney);
    }

    function testFail_transferFrom_1() {
        perform_transfer     (alice,  1 wei, bob, carol);
    }

    function testFail_transferFrom_2() {
        perform_deposit      (alice,  7 finney);
        perform_approval     (alice,  3 finney, bob);
        perform_transfer     (bob,    4 finney, alice, carol);
    }

    function test_transferFrom() {
        expectEventsExact    (weth);

        perform_deposit      (alice,  7 finney);
        perform_approval     (alice,  5 finney, bob);
        assert_weth_balance  (alice,  7 finney);
        assert_allowance     (bob,    5 finney, alice);
        assert_weth_supply   (7 finney);

        perform_transfer     (bob,    3 finney, alice, carol);
        assert_weth_balance  (alice,  4 finney);
        assert_weth_balance  (bob,    0 finney);
        assert_weth_balance  (carol,  3 finney);
        assert_allowance     (bob,    2 finney, alice);
        assert_weth_supply   (7 finney);

        perform_transfer     (bob,    2 finney, alice, carol);
        assert_weth_balance  (alice,  2 finney);
        assert_weth_balance  (bob,    0 finney);
        assert_weth_balance  (carol,  5 finney);
        assert_allowance     (bob,    0 finney, alice);
        assert_weth_supply   (7 finney);
    }

    //------------------------------------------------------------------
    // Helper functions
    //------------------------------------------------------------------

    function assert_eth_balance(Person person, uint balance) {
        assertEq(person.balance, balance);
    }

    function assert_weth_balance(Person person, uint balance) {
        assertEq(weth.balanceOf(person), balance);
    }

    function assert_weth_supply(uint supply) {
        assertEq(weth.totalSupply(), supply);
    }

    function perform_deposit(Person owner, uint value) {
        Deposit(owner, value);
        owner.deposit.value(value)();
    }

    function perform_withdrawal(Person owner, uint value) {
        Withdrawal(owner, value);
        owner.withdraw(value);
    }

    function perform_transfer(
        Person owner, uint value, Person recipient
    ) {
        Transfer(owner, recipient, value);
        owner.transfer(recipient, value);
    }

    function perform_approval(Person owner, uint value, Person spender) {
        Approval(owner, spender, value);
        owner.approve(spender, value);
    }

    function assert_allowance(Person spender, uint value, Person owner) {
        assertEq(weth.allowance(owner, spender), value);
    }

    function perform_transfer(
        Person spender, uint value, Person owner, Person recipient
    ) {
        Transfer(owner, recipient, value);
        spender.transfer(owner, recipient, value);
    }
}

contract Person {
    WETH8 weth;
    
    function Person(WETH8 _weth) {
        weth = _weth;
    }
    
    function deposit() payable {
        weth.deposit.value(msg.value)();
    }
    
    function withdraw(uint value) {
        weth.withdraw(value);
    }
    
    function () payable {
    }
    
    function transfer(Person recipient, uint value) {
        if (!weth.transfer(recipient, value)) throw;
    }
    
    function approve(Person spender, uint value) {
        if (!weth.approve(spender, value)) throw;
    }
    
    function transfer(Person owner, Person recipient, uint value) {
        if (!weth.transferFrom(owner, recipient, value)) throw;
    }
}
