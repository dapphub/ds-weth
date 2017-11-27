pragma solidity ^0.4.18;

import "./weth.sol";

contract WETH5 is WETHEvents {
    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }

    function() public payable {
        join();
    }

    function join() public payable {
        balanceOf[msg.sender] = add(balanceOf[msg.sender], msg.value);
    }

    function exit(uint wad) public {
        balanceOf[msg.sender] = sub(balanceOf[msg.sender], wad);
        msg.sender.transfer(wad);  // XXX
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function approve(address guy) public returns (bool) {
        allowance[msg.sender][guy] = uint(-1);
        Approval(msg.sender, guy, uint(-1));
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool) {
        if (src != msg.sender && allowance[src][dst] != uint(-1)) {
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }

        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }
}
