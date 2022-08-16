// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract WaterCoin {

    enum CoinTypes{Zone_A, Zone_B, Zone_C}

    mapping (CoinTypes => uint256) _supply;


    mapping (address => mapping (CoinTypes => uint256))   _balances;
    mapping (CoinTypes => mapping (CoinTypes => uint256)) _zoneAllowedTransfers;
    mapping (address => mapping (address => mapping (CoinTypes => uint256))) _allowances;

    address _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier ZoneTransferAllowed(CoinTypes from_coin, CoinTypes to_coin, uint256 amount){
        require (from_coin != to_coin, "Cannot convert coin to same type.");
        require (_zoneAllowedTransfers[from_coin][to_coin] >= amount, "Amount of transfer exceeds limit across zones");
        _;
    }

    function ZoneTransfer(CoinTypes from_coin, CoinTypes to_coin, address wallet, uint256 value) internal ZoneTransferAllowed(from_coin, to_coin, value) returns (bool) {
        require (_balances[wallet][from_coin] >= value, "Insufficient funds.");
        _zoneAllowedTransfers[from_coin][to_coin] -= value;
        _zoneAllowedTransfers[to_coin][from_coin] += value;
        _balances[wallet][from_coin] -= value;
        _balances[wallet][to_coin]   += value;
        return true;
    }

    function checkTransferLimit(CoinTypes from_coin, CoinTypes to_coin) public view returns (uint256){
        return _zoneAllowedTransfers[from_coin][to_coin];
    }

    function checkBalance(address _person, CoinTypes coin) internal view returns (uint256) {
        return _balances[_person][coin];
    }

    function _approve(address owner, address spender, uint256 amount, CoinTypes coin) internal virtual {
        require(owner != address(0), "WaterCoin: approve from the zero address");
        require(spender != address(0), "WaterCoin: approve to the zero address");

        _allowances[owner][spender][coin] = amount;
    }

    function checkAllowance(address owner, address spender, CoinTypes coin) internal view returns (uint256){
        return _allowances[owner][spender][coin];
    }

    modifier sufficientFunds(address owner, uint256 amount, CoinTypes coin){
        require(_balances[owner][coin] >= amount, "Insufficent funds");
        _;
    }

    function _transfer(address to, uint256 amount, CoinTypes coin) internal sufficientFunds(msg.sender, amount, coin) returns (bool){
        address from = msg.sender;

        _balances[from][coin] -= amount;
        _balances[to][coin]   += amount;

        return true;
    }

    function _transferFrom(address from, address to, uint256 amount, CoinTypes coin) internal sufficientFunds(from, amount, coin) returns (bool){
        uint256 currentAllowance = _allowances[from][to][coin];
        require(currentAllowance >= amount, "WaterCoin: transfer amount exceeds allowance");
        _balances[from][coin] -= amount;
        _balances[to][coin]   += amount;
        _approve(from, to, currentAllowance - amount, coin);
        return true;
    }

    modifier onlyOwner(){
        require (msg.sender == _owner, "Owner-only function");
        _;
    }

    function _mint(address account, uint256 amount, CoinTypes coin) internal onlyOwner() virtual returns (bool) {
        require(account != address(0), "ERC20: mint to the zero address");

        _supply[coin] += amount;
        _balances[account][coin] += amount;
        return true;
    }

    function _burn(address account, uint256 amount, CoinTypes coin) internal onlyOwner() {
        require(account != address(0), "WaterCoin: burn from the zero address");

        uint256 accountBalance = _balances[account][coin];
        require(accountBalance >= amount, "WaterCoin: burn amount exceeds balance");
        _balances[account][coin] = accountBalance - amount;
        _supply[coin] -= amount;
    }

    function _totalSupply(CoinTypes coin) internal view returns (uint256) {
        return _supply[coin];
    }

    function newSeason() external onlyOwner() {
        uint256 a_supply_ = _supply[CoinTypes.Zone_A];
        uint256 b_supply_ = _supply[CoinTypes.Zone_B];
        //uint256 c_supply_ = _supply[CoinTypes.Zone_C]; // C-supply currently doesnt matter.

        _zoneAllowedTransfers[CoinTypes.Zone_A][CoinTypes.Zone_C] = a_supply_;
        _zoneAllowedTransfers[CoinTypes.Zone_B][CoinTypes.Zone_C] = b_supply_;
        _zoneAllowedTransfers[CoinTypes.Zone_A][CoinTypes.Zone_B] = SafeMath.div(a_supply_, 2);
        _zoneAllowedTransfers[CoinTypes.Zone_B][CoinTypes.Zone_A] = SafeMath.div(b_supply_, 2);
    }

    

}