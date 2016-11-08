pragma solidity ^0.4.4;

import "dapple/test.sol";
import "weth.sol";

contract WETHTest is Test {
    event Deposit    (address indexed owner, uint value);
    event Withdrawal (address indexed owner, uint value);

    WETH weth = new WETH();

    function () payable {}

    function test_initial() {
        assertEq(weth.totalSupply(), 0);
        assertEq(weth.balanceOf(this), 0);
    }

    function test_deposit() {
        expectEventsExact(weth);

        Deposit(this, 3);
        weth.deposit.value(3)();
        assertEq(weth.balanceOf(this), 3);
        assertEq(weth.totalSupply(), 3);

        Deposit(this, 4);
        weth.deposit.value(4)();
        assertEq(weth.balanceOf(this), 7);
        assertEq(weth.totalSupply(), 7);
    }

    function testFail_withdraw() {
        weth.withdraw(1);
    }

    function test_withdraw() {
        uint original = this.balance;
        expectEventsExact(weth);

        Deposit(this, 7);
        weth.deposit.value(7)();

        Withdrawal(this, 3);
        weth.withdraw(3);
        assertEq(this.balance, original - 4);

        Withdrawal(this, 4);
        weth.withdraw(4);
        assertEq(this.balance, original);
    }
}
