// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;

import "./CertifiedUsers.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract WaterCoin is CertifiedUsers {

    enum CoinTypes{Zone_A, Zone_B, Zone_C}

    mapping (CoinTypes => uint256) _supply;

    mapping (address => mapping (CoinTypes => uint256))   _lockedFunds;
    mapping (address => mapping (CoinTypes => uint256))   _balances;
    mapping (CoinTypes => mapping (CoinTypes => uint256)) _zoneAllowedTransfers;
    mapping (address => mapping (address => mapping (CoinTypes => uint256))) _allowances;

    constructor() {
    }

    modifier ZoneTransferAllowed(uint from_coin_val, uint to_coin_val, uint256 amount){
        CoinTypes from_coin = CoinTypes(from_coin_val);
        CoinTypes to_coin = CoinTypes(to_coin_val);
        require (from_coin != to_coin, "Cannot convert coin to same type.");
        require (_zoneAllowedTransfers[from_coin][to_coin] >= amount, "Amount of transfer exceeds limit across zones");
        _;
    }

    function ZoneTransfer(uint from_coin_val, uint to_coin_val, address wallet, uint256 value) external ZoneTransferAllowed(from_coin_val, to_coin_val, value) returns (bool) {
        CoinTypes from_coin = CoinTypes(from_coin_val);
        CoinTypes to_coin = CoinTypes(to_coin_val);
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

    function checkBalance(address _person, uint coin_val) public view returns (uint256) {
        CoinTypes coin = CoinTypes(coin_val);
        return _balances[_person][coin];
    }

    function approve(address owner, address spender, uint256 amount, uint coin_val) public isCertified(spender) virtual {
        CoinTypes coin = CoinTypes(coin_val);
        require(owner != address(0), "WaterCoin: approve from the zero address");
        require(spender != address(0), "WaterCoin: approve to the zero address");

        _allowances[owner][spender][coin] = amount;
    }

    function checkAllowance(address owner, address spender, uint coin_val) external view returns (uint256){
        CoinTypes coin = CoinTypes(coin_val);
        return _allowances[owner][spender][coin];
    }

    modifier sufficientFunds(address owner, uint256 amount, uint coin_val){
        CoinTypes coin = CoinTypes(coin_val);
        require(_balances[owner][coin] >= amount, "Insufficent funds");
        _;
    }

    function transfer(address to, uint256 amount, uint coin_val) external sufficientFunds(msg.sender, amount, coin_val) isCertified(to) returns (bool){
        address from = msg.sender;
        CoinTypes coin = CoinTypes(coin_val);
        _balances[from][coin] -= amount;
        _balances[to][coin]   += amount;

        return true;
    }

    function transferFrom(address from, address to, uint256 amount, uint coin_val) external sufficientFunds(from, amount, coin_val) returns (bool){
        CoinTypes coin = CoinTypes(coin_val);
        uint256 currentAllowance = _allowances[from][to][coin];
        require(currentAllowance >= amount, "WaterCoin: transfer amount exceeds allowance");
        _balances[from][coin] -= amount;
        _balances[to][coin]   += amount;
        approve(from, to, currentAllowance - amount, coin_val);
        return true;
    }

    function mint(address account, uint256 amount, uint coin_val) external onlyOwner() isCertified(account) virtual returns (bool) {
        require(account != address(0), "ERC20: mint to the zero address");
        CoinTypes coin = CoinTypes(coin_val);

        _supply[coin] += amount;
        _balances[account][coin] += amount;
        return true;
    }

    function burn(address account, uint256 amount, uint coin_val) public onlyOwner() {
        require(account != address(0), "WaterCoin: burn from the zero address");
        CoinTypes coin = CoinTypes(coin_val);

        uint256 accountBalance = _balances[account][coin];
        require(accountBalance >= amount, "WaterCoin: burn amount exceeds balance");
        _balances[account][coin] = accountBalance - amount;
        _supply[coin] -= amount;
    }

    // Burns all coins from a given user.
    function burnAccount(address account) private onlyOwner(){
        uint256 a_balance = _balances[account][CoinTypes.Zone_A];
        uint256 b_balance = _balances[account][CoinTypes.Zone_B];
        uint256 c_balance = _balances[account][CoinTypes.Zone_C];

        burn(account, a_balance, 0); // Zone A
        burn(account, b_balance, 1); // Zone B
        burn(account, c_balance, 2); // Zone C
    } 

    // Burn all coins of all certified users.
    function burnAll() external onlyOwner() {
        for (uint256 i=0; i< _certifiedUsers.length; i++){
            address account = _certifiedUsers[i].account;
            burnAccount(account);
        }
    }

    function removeUser(string memory name) private onlyOwner(){
        address account = CertifiedUsers.companyAccount(name);
        burnAccount(account);
        CertifiedUsers._removeUser(name);
    }

    function certifyUser(string memory name, address account) external onlyOwner(){
        CertifiedUsers._certifyUser(name, account);
    }

    function _totalSupply(uint coin_val) public view returns (uint256) {
        CoinTypes coin = CoinTypes(coin_val);
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