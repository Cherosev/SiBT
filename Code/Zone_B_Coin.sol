// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol";
import "./WaterCoin.sol";


contract Zone_B_Coin is IERC20 {

    WaterCoin wc;

    string _name;
    string _symbol;

    constructor () {
        _name = "Zone A Coin";
        _symbol = "WAC";
        wc = WaterCoin(0x9a2E12340354d2532b4247da3704D2A5d73Bd189);
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
        return wc._totalSupply(1);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return wc.checkBalance(account, 1);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        return wc.transfer(recipient, amount, 1);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return wc.checkAllowance(owner, spender, 1);
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address from = msg.sender;
        wc.approve(from, spender, amount, 1);
        emit Approval(from, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        wc.transferFrom(sender, recipient, amount, 1);
        emit Approval(sender, recipient, amount);
        return true;
    }

    function convertToZone(uint to_coin, uint256 amount) external virtual returns (bool) {
        address account = msg.sender;
        return wc.ZoneTransfer(1, to_coin, account, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address from = msg.sender;
        uint256 currentAllowance = wc.checkAllowance(from, spender, 1);
        wc.approve(from, spender, currentAllowance + addedValue, 1);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address from = msg.sender;
        uint256 currentAllowance = wc.checkAllowance(from, spender, 1);
        require(currentAllowance >= subtractedValue, "WaterCoin: decreased allowance below zero");
        wc.approve(from, spender, currentAllowance - subtractedValue, 1);

        return true;
    }

    function mint(address account, uint256 amount) external virtual {
        if (wc.mint(account, amount, 1)){
            emit Transfer(address(0), account, amount);
        }
    }

    function burn(address account, uint256 amount) external virtual {
        wc.burn(account, amount, 1);
        emit Transfer(account, address(0), amount);
    }
}