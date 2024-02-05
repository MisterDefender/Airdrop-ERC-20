// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"

contract AirdropToken is ERC20 {
    address public owner;
    constructor(address _owner, uint256 _initSupply) ERC20("AirDropToken", "ADT"){
        require(_owner != address(0), "Owner can't be zero address");
        owner  = _owner;
        _mint(owner, _initSupply * 1e18);
    }
}