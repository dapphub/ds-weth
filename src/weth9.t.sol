pragma solidity ^0.4.18;

import "ds-test/test.sol";

import "./weth9.sol";

contract WETH9Test is DSTest, WETHEvents {
    WETH  weth;
    Guy   a;
    Guy   b;
    Guy   c;

    function setUp() public {
        weth  = this.newWETH();
        a     = this.newGuy();
        b     = this.newGuy();
        c     = this.newGuy();
    }

    function newWETH() public returns (WETH) {
        // Need cast here because Solidity is silly
        return WETH(new WETH9());
    }

    function newGuy() public returns (Guy) {
        return new Guy(weth);
    }

    function test_initial_state() public {
        assert_eth_balance   (a, 0 finney);
        assert_weth_balance  (a, 0 finney);
        assert_eth_balance   (b, 0 finney);
        assert_weth_balance  (b, 0 finney);
        assert_eth_balance   (c, 0 finney);
        assert_weth_balance  (c, 0 finney);

        assert_weth_supply   (0 finney);
    }

    function test_join() public {
        expectEventsExact    (weth);

        perform_join         (a, 3 finney);
        assert_weth_balance  (a, 3 finney);
        assert_weth_balance  (b, 0 finney);
        assert_eth_balance   (a, 0 finney);
        assert_weth_supply   (3 finney);

        perform_join         (a, 4 finney);
        assert_weth_balance  (a, 7 finney);
        assert_weth_balance  (b, 0 finney);
        assert_eth_balance   (a, 0 finney);
        assert_weth_supply   (7 finney);

        perform_join         (b, 5 finney);
        assert_weth_balance  (b, 5 finney);
        assert_weth_balance  (a, 7 finney);
        assert_weth_supply   (12 finney);
    }

    function testFail_exital_1() public {
        perform_exit         (a, 1 wei);
    }

    function testFail_exit_2() public {
        perform_join         (a, 1 finney);
        perform_exit         (b, 1 wei);
    }

    function testFail_exit_3() public {
        perform_join         (a, 1 finney);
        perform_join         (b, 1 finney);
        perform_exit         (b, 1 finney);
        perform_exit         (b, 1 wei);
    }

    function test_exit() public {
        expectEventsExact    (weth);

        perform_join         (a, 7 finney);
        assert_weth_balance  (a, 7 finney);
        assert_eth_balance   (a, 0 finney);

        perform_exit         (a, 3 finney);
        assert_weth_balance  (a, 4 finney);
        assert_eth_balance   (a, 3 finney);

        perform_exit         (a, 4 finney);
        assert_weth_balance  (a, 0 finney);
        assert_eth_balance   (a, 7 finney);
    }

    function testFail_transfer_1() public {
        perform_transfer     (a, 1 wei, b);
    }

    function testFail_transfer_2() public {
        perform_join         (a, 1 finney);
        perform_exit         (a, 1 finney);
        perform_transfer     (a, 1 wei, b);
    }

    function test_transfer() public {
        expectEventsExact    (weth);

        perform_join         (a, 7 finney);
        perform_transfer     (a, 3 finney, b);
        assert_weth_balance  (a, 4 finney);
        assert_weth_balance  (b, 3 finney);
        assert_weth_supply   (7 finney);
    }

    function testFail_transferFrom_1() public {
        perform_transfer     (a,  1 wei, b, c);
    }

    function testFail_transferFrom_2() public {
        perform_join         (a, 7 finney);
        perform_approval     (a, 3 finney, b);
        perform_transfer     (b, 4 finney, a, c);
    }

    function test_transferFrom() public {
        expectEventsExact    (weth);

        perform_join         (a, 7 finney);
        perform_approval     (a, 5 finney, b);
        assert_weth_balance  (a, 7 finney);
        assert_allowance     (b, 5 finney, a);
        assert_weth_supply   (7 finney);

        perform_transfer     (b, 3 finney, a, c);
        assert_weth_balance  (a, 4 finney);
        assert_weth_balance  (b, 0 finney);
        assert_weth_balance  (c, 3 finney);
        assert_allowance     (b, 2 finney, a);
        assert_weth_supply   (7 finney);

        perform_transfer     (b, 2 finney, a, c);
        assert_weth_balance  (a, 2 finney);
        assert_weth_balance  (b, 0 finney);
        assert_weth_balance  (c, 5 finney);
        assert_allowance     (b, 0 finney, a);
        assert_weth_supply   (7 finney);
    }

    //------------------------------------------------------------------
    // Helper functions
    //------------------------------------------------------------------

    function assert_eth_balance(Guy guy, uint balance) public {
        assertEq(guy.balance, balance);
    }

    function assert_weth_balance(Guy guy, uint balance) public {
        assertEq(weth.balanceOf(guy), balance);
    }

    function assert_weth_supply(uint supply) public {
        assertEq(weth.totalSupply(), supply);
    }

    function perform_join(Guy guy, uint wad) public {
        Join(guy, wad);
        guy.join.value(wad)();
    }

    function perform_exit(Guy guy, uint wad) public {
        Exit(guy, wad);
        guy.exit(wad);
    }

    function perform_transfer(
        Guy src, uint wad, Guy dst
    ) public {
        Transfer(src, dst, wad);
        src.transfer(dst, wad);
    }

    function perform_approval(
        Guy src, uint wad, Guy guy
    ) public {
        Approval(src, guy, wad);
        src.approve(guy, wad);
    }

    function assert_allowance(
        Guy guy, uint wad, Guy src
    ) public {
        assertEq(weth.allowance(src, guy), wad);
    }

    function perform_transfer(
        Guy guy, uint wad, Guy src, Guy dst
    ) public {
        Transfer(src, dst, wad);
        guy.transfer(src, dst, wad);
    }
}

contract Guy {
    WETH weth;

    function Guy(WETH _weth) public {
        weth = _weth;
    }

    function join() payable public {
        weth.join.value(msg.value)();
    }

    function exit(uint wad) public {
        weth.exit(wad);
    }

    function () public payable {
    }

    function transfer(Guy dst, uint wad) public {
        require(weth.transfer(dst, wad));
    }

    function approve(Guy guy, uint wad) public {
        require(weth.approve(guy, wad));
    }

    function transfer(Guy src, Guy dst, uint wad) public {
        require(weth.transferFrom(src, dst, wad));
    }
}
