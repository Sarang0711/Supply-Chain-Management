// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./erc20Interface.sol";
contract ERC20Token is IERC20 {
    uint256 public totSupply;
    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;
    mapping (address => uint256) public balance;
    mapping (address => mapping(address => uint256)) public allowed;

    string public name;
    string public symbol;
    uint256 public decimals;

    constructor (
        uint256 _initialSupply,
        string memory _tokenName,
        uint256 _decimals,
        string memory _tokenSymbol
    )   {
        balance[msg.sender] = _initialSupply;
        totSupply = _initialSupply;
        name = _tokenName;
        decimals = _decimals;
        symbol = _tokenSymbol;
    }
    function totalSupply() external view returns (uint256) {
        return totSupply;
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        require(balance[msg.sender] > _amount, "Insufficient funds in account");
        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return balance[_account];
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        require(allowed[_from][msg.sender] > _amount && balance[_from] > _amount, "Insufficient allowed funds for transfer source ");
        balance[_from] -= _amount;
        balance[_to] += _amount;
        if(allowed[_from][msg.sender] < MAX_UINT256) {
            allowed[_from][msg.sender] -= _amount;
        }
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

}