pragma solidity ^0.4.18;

import "./weth.sol";

// Can't implement WETH because Solidity is silly
contract WETH9 is WETHEvents {
    mapping (address => uint)                       balances;
    mapping (address => mapping (address => uint))  allowances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint wad) public {
        require(balances[msg.sender] >= wad);
        balances[msg.sender] -= wad;
        require(msg.sender.send(wad)); // XXX
    }

    function balanceOf(address guy) public view returns (uint) {
        return balances[guy];
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function allowance(
        address src, address guy
    ) public view returns (uint) {
        return allowances[src][guy];
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowances[msg.sender][guy] = wad;
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool) {
        require(balances[src] >= wad);

        if (src != msg.sender) {
            require(allowances[src][msg.sender] >= wad);
            allowances[src][msg.sender] -= wad;
        }

        balances[src] -= wad;
        balances[dst] += wad;

        return true;
    }
}
