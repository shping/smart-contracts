pragma solidity ^0.4.16;

contract ShpingCoin {

    struct PlatinumStruct {
        bool isPlatinum;
    }

    string public name = "Shping Coin"; 
    string public symbol = "SHC";
    uint8 public decimals = 18;
    uint public coinsaleDeadline = 1521845940; // 23/03/2018, 22:59:00 GMT | 23/03/2018, 23:59:00 CET | Saturday, 24 March 2018 9:59:00 AM GMT+11:00

    uint256 _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    mapping(address => PlatinumStruct) platinum_users;
    mapping(address => mapping(string => uint256)) campaigns; // Requests for a campaign activation 
    mapping(address => uint256) budgets; // Account budget for rewards campaigns

    address public owner;
    address public operator;

    function ShpingCoin() public {
        owner = msg.sender;
        _totalSupply = 10000000000 * 10 ** uint256(decimals);
        balances[msg.sender] = _totalSupply;
        operator = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }

    function changeOperator(address newOperator) public onlyOwner {
        require(newOperator != address(0));
        require(balances[newOperator]+balances[operator] >= balances[newOperator]);
        if (operator != owner) {
            balances[newOperator] += balances[operator];
            balances[operator] = 0;
        }
        operator = newOperator;
    }

    //Permanent platinum level

    function isPlatinumLevel(address user) public constant returns (bool) {
        return platinum_users[user].isPlatinum;
    }

    function setPermanentPlatinumLevel(address user) public onlyOwner returns (bool) {
        require(!isPlatinumLevel(user));
        platinum_users[user].isPlatinum = true;
        return true;
    }

    //Rewards campaigns
    function activateCampaign(string campaign, uint256 budget) public returns (bool) {
        require(campaigns[msg.sender][campaign] == 0);
        require(budget != 0);
        require(balances[msg.sender] - budgets[msg.sender] >= budget);
        campaigns[msg.sender][campaign] = budget;
        Activate(msg.sender, campaign, budget);
        return true;
    }

    function getBudget(address account) public constant returns (uint256) {
        return budgets[account];
    }

    function setBudget(address account, string campaign) public onlyOperator returns (bool) {
        require(account != address(0));
        require(campaigns[account][campaign] != 0);
        require(balances[account] >= budgets[account]);
        require(balances[account] - budgets[account] >= campaigns[account][campaign]);
        budgets[account] += campaigns[account][campaign];
        campaigns[account][campaign] = 0;
        return true;
    }

    function releaseBudget(address account, uint256 budget) public onlyOperator returns (bool) {
        require(account != address(0));
        require(budget != 0);
        require(budgets[account] >= budget);
        require(balances[account] >= budget);

        budgets[account] -= budget;
        balances[account] -= budget;
        balances[operator] += budget;
        Released(account, budget);
        return true;
    }

    function clearBudget(address account) public onlyOperator returns (bool) {
        budgets[account] = 0;
        return true;
    }

    event Activate(address indexed account, string indexed campaign, uint256 budget);
    event Released(address indexed account, uint256 value);

    //ERC20 interface
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public constant returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(msg.sender == owner || msg.sender == operator || now > coinsaleDeadline);
        require(balances[msg.sender] >= budgets[msg.sender] + value);
        require(balances[to] + value > balances[to]);
        
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from == owner || from == operator || msg.sender == owner || msg.sender == operator || now > coinsaleDeadline);
        require(balances[from] >= budgets[from] + value);
        require(allowed[from][msg.sender] >= value);
        require(balances[to] + value > balances[to]);

        balances[from] -= value;
        allowed[from][msg.sender] -= value;
        balances[to] += value;
        Transfer(from, to, value);
        return true;
    }

    function approve(address to, uint256 value) public returns (bool) {
        allowed[msg.sender][to] = value;
        Approval(msg.sender, to, value);
        return true;
    }

    function allowance(address account, address spender) public constant returns (uint256) {
        return allowed[account][spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}