pragma solidity ^0.4.18;

import "erc20/erc20.sol";

contract WETHEvents is ERC20Events {
    event Deposit      (address indexed dst, uint wad);
    event Withdrawal   (address indexed src, uint wad);
}

contract WETH is ERC20, WETHEvents {
    function deposit() public payable;
    function withdraw(uint wad) public;
}
