pragma solidity ^0.4.18;

import "./weth9.t.sol";
import "./weth5.sol";

contract WETH5Test is WETH9Test {
    function newWETH() public returns (WETH) {
        return WETH(new WETH5());
    }
}
