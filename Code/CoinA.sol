
contract ERC20 {

    enum CoinTypes{A, B, C}

    uint256 _CoinASupply;
    uint256 _CoinBSupply;
    uint256 _CoinCSupply;

    uint256 _totalSupply;

    address _owner;

    mapping (address => mapping (CoinTypes => uint256)) _balances;


    event Transfer(CoinTypes coin, address indexed from, address indexed to, uint256 value);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "sender is not owner");
        _;
    }

    modifier invariance() {
        uint256 oldTotalSupply = _totalSupply;
        _;
        uint256 newTotalSupply = _totalSupply;
        require (oldTotalSupply == newTotalSupply, "invariance found");
    }

    function name() external pure returns (string memory) {
        return "Water Coin";
    }

    function symbol() external pure returns (string memory) {

        return "WAC";
    }

    function decimals () external pure returns (uint) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(CoinTypes coin, address _person) external view returns (uint256) {
        return _balances[_person][coin];
    }

    function transfer (CoinTypes coin, address _to, uint256 _value) external invariance returns (bool) {
        address from = msg.sender;

        require(_balances[from][coin] >= _value);

        _balances[from][coin] -= _value;
        _balances[_to][coin] += _value;

        emit Transfer(coin, from, _to, _value);

        return true;
    }

    function mint(CoinTypes coin, uint256 _value) external onlyOwner returns (bool) {
        address from = msg.sender;

        require(_owner == from, "sender is not owner");

        _balances[from][coin] += _value;
        _totalSupply += _value;

        if (coin == CoinTypes.A){
            _CoinASupply += _value;
        }
        if (coin == CoinTypes.B){
            _CoinBSupply += _value;
        }
        if (coin == CoinTypes.C) {
            _CoinCSupply += _value;
        }

        return true;
    }

}