// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "./WaterCoin.sol";


contract Zone_C_Coin is IERC20, WaterCoin {

    string _name;
    string _symbol;

    constructor () {
        _name = "Zone C Coin";
        _symbol = "WCC";
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return WaterCoin._totalSupply(CoinTypes.Zone_B);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return WaterCoin.checkBalance(account, CoinTypes.Zone_B);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return WaterCoin._transfer(recipient, amount, WaterCoin.CoinTypes.Zone_B);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return WaterCoin.checkAllowance(owner, spender, CoinTypes.Zone_B);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address from = msg.sender;
        WaterCoin._approve(from, spender, amount, CoinTypes.Zone_B);
        emit Approval(from, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        WaterCoin._transferFrom(sender, recipient, amount, CoinTypes.Zone_B);
        emit Approval(sender, recipient, amount);
        return true;
    }

    function convertToZone(CoinTypes to_coin, uint256 amount) external virtual returns (bool) {
        address account = msg.sender;
        return WaterCoin.ZoneTransfer(CoinTypes.Zone_B, to_coin, account, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address from = msg.sender;
        uint256 currentAllowance = WaterCoin.checkAllowance(from, spender, CoinTypes.Zone_B);
        WaterCoin._approve(from, spender, currentAllowance + addedValue, CoinTypes.Zone_B);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address from = msg.sender;
        uint256 currentAllowance = WaterCoin.checkAllowance(from, spender, CoinTypes.Zone_B);
        require(currentAllowance >= subtractedValue, "WaterCoin: decreased allowance below zero");
        WaterCoin._approve(from, spender, currentAllowance - subtractedValue, CoinTypes.Zone_B);

        return true;
    }

    function mint(address account, uint256 amount) external virtual {
        if (WaterCoin._mint(account, amount, CoinTypes.Zone_B)){
            emit Transfer(address(0), account, amount);
        }
    }

    function burn(address account, uint256 amount) external virtual {
        WaterCoin._burn(account, amount, CoinTypes.Zone_B);
        emit Transfer(account, address(0), amount);
    }
}