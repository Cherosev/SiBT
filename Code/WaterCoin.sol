// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract WaterCoin {

    enum CoinTypes{Zone_A, Zone_B, Zone_C}

    mapping (CoinTypes => uint256) _supply;


    mapping (address => mapping (CoinTypes => uint256)) _balances;
    mapping (CoinTypes => mapping (CoinTypes => uint256)) _zoneAllowedTransfers;

    address _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier ZoneTransferAllowed(CoinTypes from_coin, CoinTypes to_coin, uint256 amount){
        if (from_coin != to_coin){
           require (_zoneAllowedTransfers[from_coin][to_coin] >= amount, "Amount of transfer exceeds limit across zones");
        }
        _;
    }

    function ZoneTransferControl(CoinTypes from_coin, CoinTypes to_coin, uint256 value) private ZoneTransferAllowed(from_coin, to_coin, value) returns (bool) {
        if (from_coin != to_coin){
            _zoneAllowedTransfers[from_coin][to_coin] -= value;
            _zoneAllowedTransfers[to_coin][from_coin] += value;
        }
        return true;
    }

    function checkTransferLimit(CoinTypes from_coin, CoinTypes to_coin) public view returns (uint256){
        return _zoneAllowedTransfers[from_coin][to_coin];
    }

    function checkBalance(address _person, CoinTypes coin) external view returns (uint256) {
        return _balances[_person][coin];
    }

    function transfer(address to, uint256 amount, CoinTypes coin) external returns (bool){
        address from = msg.sender;
        require(_balances[from][coin] >= amount, "Insufficent funds");

        _balances[from][coin] -= amount;
        _balances[to][coin]   += amount;

        return true;
    }

    

    function totalSupply(CoinTypes coin) external view returns (uint256) {
        return _supply[coin];
    }

    function newSeason(uint256 a_supply_, uint256 b_supply_, uint256 c_supply_) external {
        address from = msg.sender;

        require(from == _owner, "Only owner can start new season");

        _supply[CoinTypes.Zone_A] = a_supply_;
        _supply[CoinTypes.Zone_B] = b_supply_;
        _supply[CoinTypes.Zone_C] = c_supply_;

        _zoneAllowedTransfers[CoinTypes.Zone_A][CoinTypes.Zone_C] = a_supply_;
        _zoneAllowedTransfers[CoinTypes.Zone_B][CoinTypes.Zone_C] = b_supply_;
        _zoneAllowedTransfers[CoinTypes.Zone_A][CoinTypes.Zone_B] = SafeMath.div(a_supply_, 2);
        _zoneAllowedTransfers[CoinTypes.Zone_B][CoinTypes.Zone_A] = SafeMath.div(b_supply_, 2);
    }

    

}