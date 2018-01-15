# Shping smart contracts

## Shping coin

### Actors

Three actors work with the contract: "Owner", "Operator" and "User". "User" is anyone who communicates with Shping coins, who calls contract methods. "Owner" is a user who creates the contract and stores an initial amount of coins. "Operator" is a Shping operations account which is defined by the owner. "Operator" receives started coins from the owner, communicates with brands and mobile users and stores transition coins of mobile users.

![Use Cases](https://raw.githubusercontent.com/shping/smart-contracts/master/media/SHC%20Use%20Cases.png)

### Contract initialization and ERC20
The contract is started with the following initial values and implements an ERC20 interface.

```javascript
string public name = "Shping Coin"; 
string public symbol = "SHPING";
uint8 public decimals = 18;
uint public coinsaleDeadline = 1521845940;

function ShpingCoin() public {
    owner = msg.sender;
    _totalSupply = 10000000000 * 10 ** uint256(decimals);
    balances[msg.sender] = _totalSupply;
    operator = msg.sender;
}

function totalSupply() public constant returns (uint256);
function balanceOf(address account) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address to, uint256 value) public returns (bool);
function allowance(address account, address spender) public constant returns (uint256);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
```
As you see, "Owner" initially is a contract's operator but the owner's first task is to define an operator. Pay attention also to "coinsaleDeadline", it's a timestamp for 23/03/2018, 22:59:00 GMT and the contract uses this value for restrictions in ERC20 methods "transfer" and "transferFrom"

```javascript
function transfer(address to, uint256 value) public returns (bool) {
    require(msg.sender == owner || msg.sender == operator || now > coinsaleDeadline);
    ...

function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(from == owner || from == operator || msg.sender == owner || msg.sender == operator || now > coinsaleDeadline);
    ...
```

As a result, only "Owner" or "Operator" has permission to transfer coins until the token sale campaign is complete.

### Platinum level

Additionally, the owner can reward any user with a permanent platinum level in the Shping mobile app.

```javascript
struct PlatinumStruct {
    bool isPlatinum;
}

mapping(address => mapping(string => PlatinumStruct)) platinum_users;

function changeOperator(address newOperator) public onlyOwner;
function isPlatinumLevel(address user, string hashedID) public constant returns (bool);
function setPermanentPlatinumLevel(address user, string hashedID) public onlyOwner returns (bool);
```

"Platinum Level" is a term from the Shping mobile application. Registered users start with a "Basic" level and go through "Bronze", "Silver", "Gold" to "Platinum". Each level gives additional multiplicator for earned coins. "Platinum" level that is received from "Owner" is a permanent status which can't be cancelled.

### Brands rewards campaigns
The next part of the contract is methods for working with rewards campaigns. Brand's representer can request to activate a rewards campaign with a budget using method "activateCampaign". "Operator" monitors "Activate" events and activates a brand's campaign. Requested campaign's value is added to brand's total budget for rewards campaigns. Only this budget can be used for campaign events rewarded to users. The approved budget can be received at any time by method "getBudget".

```javascript
function activateCampaign(string campaign, uint256 budget) public returns (bool);
function getBudget(address account) public constant returns (uint256);
function setBudget(address account, string campaign) public onlyOperator returns(bool);
event Activate(address indexed account, string campaign);
```
Periodically (every month) the operator releases budgets, and transfers coins to the operator account. These coins will be transferred to consumers accounts by request. The operator can also clear any budget. This is a service function which allows them to cancel a campaign and unblock a brand's coins.

```javascript
function releaseBudget(address account, uint256 budget) public onlyOperator returns (bool);
function clearBudget(address account) public onlyOperator returns (bool);
event Released(address indexed account, uint256 value);
```

### Users coins
Users scan barcodes, and earn coins for reviews and entering product information. As a result, their coins temporarily are stored on the transition ("Operator") account. At any time they can be requested to transfer to another account and the "Operator" will perform this operation using ERC20 methods.