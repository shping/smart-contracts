# Shping smart contracts

## Shping coin

### Use Cases

![Use Cases](https://raw.githubusercontent.com/shping/smart-contracts/master/media/SHC%20Use%20Cases.png)

1. An owner is an user who create a contract. Also the owner becomes a contract's operator who executes common operations.
2. The owner chooses a new operator
3. Also the owner can reward any user with a permanent platinum level in Shping mobile app.
4. Shping coin contract implements ERC20 interface so any users can performs these operations
5. Any user can request to activate a rewards campaign with requested budget.
6. Any user can get an amount of the approved budget
7. The operator monitors "Activate" event and activates an user's campaign
8. Periodically the operator releases budgets and transfers coins to the operator account. These coins will be transferred to consumers accounts by a request.
9. The operator can clear any budget. 