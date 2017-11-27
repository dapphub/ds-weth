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
        deposit();
    }

    function deposit() public payable {
        balanceOf[msg.sender] = add(balanceOf[msg.sender], msg.value);
    }

    function withdraw(uint wad) public {
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

    function approve(address guy) public returns (bool) {
        return approve(guy, uint(-1));
    }
    function join() public payable {
        deposit();
    }
    function exit(uint wad) public {
        withdraw(wad);
    }
    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }
}
