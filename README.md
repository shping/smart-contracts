# Shping smart contracts

## Shping coin

### Use Cases

![Use Cases](https://raw.githubusercontent.com/shping/smart-contracts/master/media/SHC%20Use%20Cases.png)

1. An owner is a user who creates a contract. The owner also becomes a contract's operator who executes common operations.
2. The owner chooses a new operator
3. The owner can also reward any user with a permanent platinum level in the Shping mobile app.
4. The Shping coin contract implements an ERC20 interface so that any user can perform these operations
5. Any user can request to activate a rewards campaign with requested budget
6. Any user can get an amount of the approved budget
7. The operator monitors "Activate" events and activates a user's campaign
8. Periodically the operator releases budgets and transfers coins to the operator account. These coins will be transferred to consumers accounts by request.
9.  The operator can clear any budget