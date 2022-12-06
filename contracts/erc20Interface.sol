// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC20 {

function totalSupply() external view returns (uint);
function balanceOf(address _account) external view returns (uint);
function transfer(address _to, uint _tokens) external returns (bool);
function allowance(address _owner,address _spender) external view returns (uint);
function transferFrom(address _from, address _to, uint tokens) external returns (bool);
function approve(address _to, uint _tokens) external returns (bool);


event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _from, address indexed _spender, uint _value);
}

