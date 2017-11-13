pragma solidity ^0.4.18;

import "ds-test/test.sol";

import "./weth.sol";

contract WETHTest is DSTest, WETHEvents {
    WETH    weth   = new WETH();
    Person  alice  = new Person(weth);
    Person  bob    = new Person(weth);
    Person  carol  = new Person(weth);

    function test_initial_state() public {
        assert_eth_balance   (alice, 0 finney);
        assert_weth_balance  (alice, 0 finney);
        assert_eth_balance   (bob,   0 finney);
        assert_weth_balance  (bob,   0 finney);
        assert_eth_balance   (carol, 0 finney);
        assert_weth_balance  (carol, 0 finney);

        assert_weth_supply   (0 finney);
    }

    function test_deposit() public {
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

    function testFail_withdrawal_1() public {
        perform_withdrawal   (alice,  1 wei);
    }

    function testFail_withdrawal_2() public {
        perform_deposit      (alice,  1 finney);
        perform_withdrawal   (bob,    1 wei);
    }

    function testFail_withdrawal_3() public {
        perform_deposit      (alice,  1 finney);
        perform_deposit      (bob,    1 finney);
        perform_withdrawal   (bob,    1 finney);
        perform_withdrawal   (bob,    1 wei);
    }

    function test_withdrawal() public {
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

    function testFail_transfer_1() public {
        perform_transfer     (alice,  1 wei, bob);
    }

    function testFail_transfer_2() public {
        perform_deposit      (alice,  1 finney);
        perform_withdrawal   (alice,  1 finney);
        perform_transfer     (alice,  1 wei, bob);
    }

    function test_transfer() public {
        expectEventsExact    (weth);

        perform_deposit      (alice,  7 finney);
        perform_transfer     (alice,  3 finney, bob);
        assert_weth_balance  (alice,  4 finney);
        assert_weth_balance  (bob,    3 finney);
        assert_weth_supply   (7 finney);
    }

    function testFail_transferFrom_1() public {
        perform_transfer     (alice,  1 wei, bob, carol);
    }

    function testFail_transferFrom_2() public {
        perform_deposit      (alice,  7 finney);
        perform_approval     (alice,  3 finney, bob);
        perform_transfer     (bob,    4 finney, alice, carol);
    }

    function test_transferFrom() public {
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

    function assert_eth_balance(Person person, uint balance) public {
        assertEq(person.balance, balance);
    }

    function assert_weth_balance(Person person, uint balance) public {
        assertEq(weth.balanceOf(person), balance);
    }

    function assert_weth_supply(uint supply) public {
        assertEq(weth.totalSupply(), supply);
    }

    function perform_deposit(Person owner, uint value) public {
        Deposit(owner, value);
        owner.deposit.value(value)();
    }

    function perform_withdrawal(Person owner, uint value) public {
        Withdrawal(owner, value);
        owner.withdraw(value);
    }

    function perform_transfer(
        Person owner, uint value, Person recipient
    ) public {
        Transfer(owner, recipient, value);
        owner.transfer(recipient, value);
    }

    function perform_approval(
        Person owner, uint value, Person spender
    ) public {
        Approval(owner, spender, value);
        owner.approve(spender, value);
    }

    function assert_allowance(
        Person spender, uint value, Person owner
    ) public {
        assertEq(weth.allowance(owner, spender), value);
    }

    function perform_transfer(
        Person spender, uint value, Person owner, Person recipient
    ) public {
        Transfer(owner, recipient, value);
        spender.transfer(owner, recipient, value);
    }
}

contract Person {
    WETH weth;

    function Person(WETH _weth) public {
        weth = _weth;
    }

    function deposit() payable public {
        weth.deposit.value(msg.value)();
    }

    function withdraw(uint value) public {
        weth.withdraw(value);
    }

    function () payable public {
    }

    function transfer(Person recipient, uint value) public {
        require(weth.transfer(recipient, value));
    }

    function approve(Person spender, uint value) public {
        require(weth.approve(spender, value));
    }

    function transfer(Person owner, Person recipient, uint value) public {
        require(weth.transferFrom(owner, recipient, value));
    }
}
