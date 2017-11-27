pragma solidity ^0.4.18;

import "./weth9.t.sol";
import "./weth5.sol";

contract WETH5Test is WETH9Test {
    function newWETH() public returns (WETH) {
        return WETH(new WETH5());
    }
}

contract TokenUser {
    WETH5  token;

    function TokenUser(WETH5 token_) public {
        token = token_;
    }

    function doTransferFrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint amount)
        public
        returns (bool)
    {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        public
        view
        returns (uint)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) public view returns (uint) {
        return token.balanceOf(who);
    }

    function doApprove(address guy)
        public
        returns (bool)
    {
        return token.approve(guy);
    }
    function doPush(address who, uint amount) public {
        token.push(who, amount);
    }
    function doPull(address who, uint amount) public {
        token.pull(who, amount);
    }
    function doMove(address src, address dst, uint amount) public {
        token.move(src, dst, amount);
    }
}

contract WETH5TokenBaseTest is DSTest {
    uint constant initialBalance = 1000;

    WETH5 token;
    TokenUser user1;
    TokenUser user2;

    function setUp() public {
        token = createToken();
        user1 = new TokenUser(token);
        user2 = new TokenUser(token);
    }

    function createToken() internal returns (WETH5 weth) {
        weth = new WETH5();
        weth.join.value(initialBalance)();
    }

    function testSetupPrecondition() public {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() public logs_gas() {
        token.transfer(address(0), 10);
    }

    function testAllowanceStartsAtZero() public logs_gas {
        assertEq(token.allowance(user1, user2), 0);
    }

    function testValidTransfers() public logs_gas {
        uint sentAmount = 250;
        log_named_address("token11111", token);
        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(this), initialBalance - sentAmount);
    }

    function testFailWrongAccountTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transferFrom(user2, this, sentAmount);
    }

    function testFailInsufficientFundsTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transfer(user1, initialBalance - sentAmount);
        token.transfer(user2, sentAmount+1);
    }

    function testTransferFromSelf() public {
        // you always approve yourself
        assertEq(token.allowance(this, this), 0);
        token.transferFrom(this, user1, 50);
        assertEq(token.balanceOf(user1), 50);
    }
    function testFailTransferFromSelfNonArbitrarySize() public {
        // you shouldn't be able to evade balance checks by transferring
        // to yourself
        token.transferFrom(this, this, token.balanceOf(this) + 1);
    }


    function testApproveSetsAllowance() public logs_gas {
        log_named_address("Test", this);
        log_named_address("Token", token);
        log_named_address("Me", this);
        log_named_address("User 2", user2);
        token.approve(user2, 25);
        assertEq(token.allowance(this, user2), 25);
    }

    function testChargesAmountApproved() public logs_gas {
        uint amountApproved = 20;
        token.approve(user2, amountApproved);
        assertTrue(user2.doTransferFrom(this, user2, amountApproved));
        assertEq(token.balanceOf(this), initialBalance - amountApproved);
    }

    function testFailTransferWithoutApproval() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        token.transferFrom(user1, self, 1);
    }

    function testFailChargeMoreThanApproved() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        user1.doApprove(self, 20);
        token.transferFrom(user1, self, 21);
    }
}


contract WETH5TokenTest is DSTest {
    uint constant initialBalance = 1000;

    WETH5 token;
    TokenUser user1;
    TokenUser user2;

    function setUp() public {
        token = createToken();
        user1 = new TokenUser(token);
        user2 = new TokenUser(token);
    }

    function createToken() internal returns (WETH5 weth) {
        weth = new WETH5();
        weth.join.value(initialBalance)();
    }

    function testSetupPrecondition() public {
        assertEq(token.balanceOf(this), initialBalance);
    }

    function testTransferCost() public logs_gas {
        token.transfer(address(0), 10);
    }

    function testAllowanceStartsAtZero() public logs_gas {
        assertEq(token.allowance(user1, user2), 0);
    }

    function testValidTransfers() public logs_gas {
        uint sentAmount = 250;
        log_named_address("token11111", token);
        token.transfer(user2, sentAmount);
        assertEq(token.balanceOf(user2), sentAmount);
        assertEq(token.balanceOf(this), initialBalance - sentAmount);
    }

    function testFailWrongAccountTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transferFrom(user2, this, sentAmount);
    }

    function testFailInsufficientFundsTransfers() public logs_gas {
        uint sentAmount = 250;
        token.transfer(user1, initialBalance - sentAmount);
        token.transfer(user2, sentAmount + 1);
    }

    function testApproveSetsAllowance() public logs_gas {
        log_named_address("Test", this);
        log_named_address("Token", token);
        log_named_address("Me", this);
        log_named_address("User 2", user2);
        token.approve(user2, 25);
        assertEq(token.allowance(this, user2), 25);
    }

    function testChargesAmountApproved() public logs_gas {
        uint amountApproved = 20;
        token.approve(user2, amountApproved);
        assertTrue(user2.doTransferFrom(this, user2, amountApproved));
        assertEq(token.balanceOf(this), initialBalance - amountApproved);
    }

    function testFailTransferWithoutApproval() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        token.transferFrom(user1, self, 1);
    }

    function testFailChargeMoreThanApproved() public logs_gas {
        address self = this;
        token.transfer(user1, 50);
        user1.doApprove(self, 20);
        token.transferFrom(user1, self, 21);
    }
    function testTransferFromSelf() public {
        token.transferFrom(this, user1, 50);
        assertEq(token.balanceOf(user1), 50);
    }
    function testFailTransferFromSelfNonArbitrarySize() public {
        // you shouldn't be able to evade balance checks by transferring
        // to yourself
        token.transferFrom(this, this, token.balanceOf(this) + 1);
    }

    function testFailUntrustedTransferFrom() public {
        assertEq(token.allowance(this, user2), 0);
        user1.doTransferFrom(this, user2, 200);
    }
    function testTrusting() public {
        assertEq(token.allowance(this, user2), 0);
        token.approve(user2);
        assertEq(token.allowance(this, user2), uint(-1));
        token.approve(user2, 0);
        assertEq(token.allowance(this, user2), 0);
    }
    function testTrustedTransferFrom() public {
        token.approve(user1);
        user1.doTransferFrom(this, user2, 200);
        assertEq(token.balanceOf(user2), 200);
    }

    function testPush() public {
        assertEq(token.balanceOf(this), 1000);
        assertEq(token.balanceOf(user1), 0);
        token.push(user1, 1000);
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 1000);
        user1.doPush(user2, 200);
        assertEq(token.balanceOf(this), 0);
        assertEq(token.balanceOf(user1), 800);
        assertEq(token.balanceOf(user2), 200);
    }
    function testFailPullWithoutTrust() public {
        user1.doPull(this, 1000);
    }
    function testPullWithTrust() public {
        token.approve(user1);
        user1.doPull(this, 1000);
    }
    function testFailMoveWithoutTrust() public {
        user1.doMove(this, user2, 1000);
    }
    function testMoveWithTrust() public {
        token.approve(user1);
        user1.doMove(this, user2, 1000);
    }
    function testApproveWillModifyAllowance() public {
        assertEq(token.allowance(this, user1), 0);
        assertEq(token.balanceOf(user1), 0);
        token.approve(user1, 1000);
        assertEq(token.allowance(this, user1), 1000);
        user1.doPull(this, 500);
        assertEq(token.balanceOf(user1), 500);
        assertEq(token.allowance(this, user1), 500);
    }
    function testApproveWillNotModifyAllowance() public {
        assertEq(token.allowance(this, user1), 0);
        assertEq(token.balanceOf(user1), 0);
        token.approve(user1);
        assertEq(token.allowance(this, user1), uint(-1));
        user1.doPull(this, 1000);
        assertEq(token.balanceOf(user1), 1000);
        assertEq(token.allowance(this, user1), uint(-1));
    }
}
