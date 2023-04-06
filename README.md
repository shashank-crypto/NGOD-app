# NGO Fund Management
## Solidity with truffle for DApp
## Blockchain for **Industry 4.0** : 


### Basic Idea: *Transparent transaction of NGOs*


Smart contract that recieves money from anyone and sends money to the addresses that the owner approves and rejects the others.


Questions (?)
- How many transactions I can handle using **smart contracts**?
- Can I handle mutiple if/else/when case using a single **Smart Contracts**?
- How to emplement stable coins inside a smart contract like **Tether**?

Points inside the app: 
- Smart contract of stable coin
- Reserve, required, goal
- Assigning addresses to the contributers
- Assigning addresses to the sellers
## Installation

Install my-project with npm
Make the right configuration inside the truffle.config.js to make connection with your Ganache server or any other servers.

```bash
  npm install -g truffle
```

```bash
  truffle compile
```

```bash
  truffle migrate
```


> NOTE : If the truffle command doesn't work you need to give the permission for the command to recognised and run from terminal. 

WorkAround : 
```
npm init
npm install truffle
```
Write a script in *package.json* and give compile and migrate inside the script and run the script.
## Features

Points:
- Create Smart contract (FundManagement)
    - Contribute (Recieve)
    - Request
    - ValidateRequest
    - Owner
    - TrustOwner
    - RevokeTrust
    - ApproveWithdrawal
    - Withdraw (onlyContributors) (can't be greater that contributed) (only after withdrawal time)
    - releaseMoney (vote on this)
    - holdMoney (once the money is gone)
    - withdrawMoney (only small contributions can withdraw their money) (not after holdMoney is executed)


- Types of contracts:
    - NGO based:
        - destructContract (can only be called by owner) => Halts everything other than withdrawMoney => state.released
        - voting rules are more strict
    - Event Based:
        - selfDestruct is called itself after the end-period
        - minimum contribution (maybe)
        - because it is for a limited period, voting for payment approval is lenient (owner would have more control in comparison)
        - setGoal (contribution is halted after this is reached unless owner requests more again with a setGoal)
    

- 
    - enum state {onHold, released}
    - selfDestruct {mapping(address => uint) contributionAmount }
        - state.release {first come first recive }
    - votingRules (state.release )
        - votingWeight > 60%
        - votingCount > 30%
    - reduce gas price before sending the money 
    - **who pays the gas when a contract function is called by the user ? - Contract oor User**



- 
    - Send tokens as proof of contribution
        - get back the tokens at the time of withdrawal (implement only at the later stage of project)

One thing that can be done here is - once the request is made and if contract doesnt have that amount, it can be kept on hold and once the it reaches the amount it needs it will release the amount. On priority basis.

- Attributes
    - contributor
    - contributorCount
    - eventName (if event basis) (not necessary)
    - owner
    - mapping(contributor => bool)



## Tech Stack

**Languages:** JavaScript, Solidity

**Tools:** Truffle, Ganache


## Feedback

If you have any feedback, please reach out to us at shashank.k.chaudhary@gmail.com


## Authors

- [@shashank-crypto](https://www.github.com/shashank-crypto)


## License

[MIT](https://choosealicense.com/licenses/mit/)

