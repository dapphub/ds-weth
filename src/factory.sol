pragma solidity >=0.4.23;

import "./weth9.sol";

contract DSWethFactory {
    event LogMake(address indexed creator, address token);

    function make() public returns (WETH9_ result) {
        result = new WETH9_();
        emit LogMake(msg.sender, address(result));
    }
}
