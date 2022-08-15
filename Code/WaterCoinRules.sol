pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract WaterCoinRules {


    enum CoinTypes{A, B, C}

    uint256 A_supply;
    uint256 B_supply;
    uint256 C_supply;

    mapping (CoinTypes => mapping (CoinTypes => uint256)) allowedTransfers;

    address _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier transferAllowed(CoinTypes from_coin, CoinTypes to_coin, uint256 amount){
        require (allowedTransfers[from_coin][to_coin] >= amount, "Amount of transfer exceeds limit across zones");
        _;
    }

    function checkTransferAllowed(CoinTypes from_coin, CoinTypes to_coin) public view returns (uint256){
        return allowedTransfers[from_coin][to_coin];
    }

    function transferControl(CoinTypes from_coin, CoinTypes to_coin, address to, uint256 value) external transferAllowed(from_coin, to_coin, value) returns (bool) {
        allowedTransfers[from_coin][to_coin] -= value;
        allowedTransfers[to_coin][from_coin] += value;
        return true;
    }


    function newSeason(uint256 a_supply_, uint256 b_supply_, uint256 c_supply_) external {
        address from = msg.sender;

        require(from == _owner, "Only owner can start new season");

        A_supply = a_supply_;
        B_supply = b_supply_;
        C_supply = c_supply_;

        allowedTransfers[CoinTypes.A][CoinTypes.C] = a_supply_;
        allowedTransfers[CoinTypes.B][CoinTypes.C] = b_supply_;
        allowedTransfers[CoinTypes.A][CoinTypes.B] = SafeMath.div(a_supply_, 2);
        allowedTransfers[CoinTypes.B][CoinTypes.A] = SafeMath.div(b_supply_, 2);
    }

    

}