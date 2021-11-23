## Blockchain for **Industry 4.0** : 

<br>

### Basic Idea: *Transparent transaction of NGOs*

<br>

Smart contract that recieves money from anyone and sends money to the addresses that the owner approves and rejects the others.

<br>

Questions (?)
- How many transactions I can handle using **smart contracts**?
- Can I handle mutiple if/else/when case using a single **Smart Contracts**?
- How to emplement stable coins inside a smart contract like **Tether**?

<br>

Points inside the app: 
- Smart contract of stable coin
- Reserve, required, goal
- Assigning addresses to the contributers
- Assigning addresses to the sellers

### **Solidity code for <span style="color:#42d4f5;">Crowd-Funding-Campaign</span>**
```
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract CrowdFundingCampaign {
    
    struct Withdrawal {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    // Withdrawal[] public withdrawals;
    
    uint numWithdrawals;
    mapping (uint => Withdrawal) withdrawals;
    address public owner;
    mapping(address => bool) contributors;
    uint public contributorsCount;
    uint public minimumContribution;
    
    constructor(uint minimum, address creator) {
        owner = creator;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value >= minimumContribution);
        contributors[msg.sender] = true;
        contributorsCount++;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyContributor() {
        require(contributors[msg.sender]);
        _;
    }
    
    function createWithdrawal(string memory description, uint value, address payable recipient) public onlyOwner {
        // Withdrawal memory newWithdrawal = Withdrawal({
        //     description: description,
        //     value: value,
        //     recipient: recipient,
        //     complete: false,
        //     approvalCount: 0
        // });
        // withdrawals.push(newWithdrawal);
        Withdrawal storage w = withdrawals[numWithdrawals++];
        w.description = description;
        w.value = value;
        w.recipient = recipient;
        w.complete = false;
        w.approvalCount = 0;
    }
    
    function approveWithdawal(uint index) public onlyContributor {
        Withdrawal storage withdrawal = withdrawals[index];
        
        require(!withdrawal.approvals[msg.sender]);
        
        withdrawal.approvals[msg.sender] = true;
        withdrawal.approvalCount++;
    }
    
    function finalizewithdrawal(uint index) public onlyOwner {
        Withdrawal storage withdrawal = withdrawals[index];
        
        require(withdrawal.approvalCount >= (contributorsCount/2));
        require(!withdrawal.complete);
        
        withdrawal.recipient.transfer(withdrawal.value);
        withdrawal.complete = true;
    }
    
}
```

Will take above code as reference for the project.

<br>

Steps:
- Set up an environment in vs-code -> *HOW?*

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

    <br>

    - releaseMoney (vote on this)
    
    - holdMoney (once the money is gone)

    - withdrawMoney (only small contributions can withdraw their money) (not after holdMoney is executed)

    <br>

<span style="color:pink">

- Types of contracts:
    - NGO based:
        - destructContract (can only be called by owner) => Halts everything other than withdrawMoney => state.released
        - voting rules are more strict
    - Event Based:
        - selfDestruct is called itself after the end-period
        - minimum contribution (maybe)
        - because it is for a limited period, voting for payment approval is lenient (owner would have more control in comparison)
        - setGoal (contribution is halted after this is reached unless owner requests more again with a setGoal)
    
</span>

<br>

<span style="color:lime">

- 
    - enum state {onHold, released}
    - selfDestruct {mapping(address => uint) contributionAmount }
        - state.release {first come first recive }
    - votingRules (state.release )
        - votingWeight > 60%
        - votingCount > 30%
    - reduce gas price before sending the money 
    - **who pays the gas when a contract function is called by the user ? - Contract oor User**

</span>

<br>

- 
    - <span style="color:#cfe82c">Send tokens as proof of contribution</span>
        - get back the tokens at the time of withdrawal (implement only at the later stage of project)

One thing that can be done here is - once the request is made and if contract doesnt have that amount, it can be kept on hold and once the it reaches the amount it needs it will release the amount. On priority basis.

- Attributes
    - contributor
    - contributorCount
    - eventName (if event basis) (not necessary)
    - owner
    - mapping(contributor => bool)


## Different versions of working code :

**<span style="color:red">Version-1</span>**
```
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract NgoFundManagement {
    
    address owner;
    uint ownerApprovalValue;
    mapping(address => bool) contributor;
    mapping(address => bool) trust;
    mapping(address => bool) canApprove;
    uint contributorCount;
    PaymentRequest[] public paymentRequests;
    
    struct PaymentRequest {
        string description;
        uint amount;
        address payable recipient;
        bool validated;
        mapping(address => bool) approval;
        uint approvalCount;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner allowed");
        _;
    }
    
    modifier onlyContributor() {
        require(contributor[msg.sender], "Only contributors allowed");
        _;
    }
    
    //error handling = require, assert, revert
    
    constructor() public {
        owner = msg.sender;
        canApprove[owner] = true;
    }
    
    function contribute() public payable {
        contributor[msg.sender] = true;
        canApprove[msg.sender] = true;
        contributorCount++;
    }
    
    function requestPayment(string memory _description, uint _amount, address payable _recipient) public {
        PaymentRequest memory newPaymentRequest = PaymentRequest({
            description: _description,
            amount: _amount,
            recipient: _recipient,
            validated: false,
            approvalCount: 0
        });
        paymentRequests.push(newPaymentRequest);
    }
    
    function validatePaymentRequest(uint index) public onlyOwner {
        PaymentRequest memory paymentRequest = paymentRequests[index];
        paymentRequest.validated = true;
    }
    
    function approvePaymentRequest(uint index) public {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        require(paymentRequest.validated);
        require(!paymentRequest.approval[msg.sender]);
        require(canApprove[msg.sender]);
        require(address(this).balance >= paymentRequest.amount);
        
        //vulnerablity : contributor trustOwner() ->Owner approvePaymentRequest()-> contributor revokeTrust() -> contributor approvePaymentRequest() 
        //this contributor can vote twice
        if(msg.sender == owner) {
            paymentRequest.approvalCount += ownerApprovalValue;
        }
        else{
            paymentRequest.approvalCount++;
        }
        paymentRequest.approval[msg.sender] = true;
        
    }
    
    function paymentRequestList() public view returns (string memory, uint, address) {
        // uint j = 0;
        // while(j != paymentRequests.length) {
        //     return (paymentRequests[j].description, paymentRequests[j].amount, paymentRequests[j],recipient);
        // }
        return(paymentRequests[0].description, paymentRequests[0].amount, paymentRequests[0].recipient);
    }
    
    // function completePaymentRequest(uint index) public onlyOwner {
    //     PaymentRequest memory paymentRequest = paymentRequests[index];
        
    //     paymentRequest.approvalCount += ownerApprovalValue;
        
    //     require(paymentRequest.approvalCount);
    // }
    
    function trustOwner() public onlyContributor {
        require(!trust[msg.sender]);
        trust[msg.sender] = true;
        canApprove[msg.sender] = false;
        ownerApprovalValue++;
    }
    
    function revokeTrust() public onlyContributor {
        require(trust[msg.sender]);
        canApprove[msg.sender] = true;
        ownerApprovalValue--;
    }
    
}
```

**<span style="color:red">Version-2</span>** (everything working inside this- without warnings)
```
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract NgoFundManagement {
    
    address owner;
    uint ownerApprovalValue;
    mapping(address => bool) contributor;
    mapping(address => bool) trust;
    mapping(address => bool) canApprove;
    uint contributorCount;
    PaymentRequest[] public paymentRequests;
    
    struct PaymentRequest {
        string description;
        uint amount;
        address payable recipient;
        // bool validated;
        uint8 validated;
        mapping(address => bool) approval;
        uint approvalCount;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner allowed");
        _;
    }
    
    modifier onlyContributor() {
        require(contributor[msg.sender], "Only contributors allowed");
        _;
    }
    
    //error handling = require, assert, revert
    
    constructor() public {
        owner = msg.sender;
        canApprove[owner] = true;
    }
    
    function contribute() public payable {
        contributor[msg.sender] = true;
        canApprove[msg.sender] = true;
        contributorCount++;
    }
    
    function requestPayment(string memory _description, uint _amount, address payable _recipient) public {
        PaymentRequest memory newPaymentRequest = PaymentRequest({
            description: _description,
            amount: _amount,
            recipient: _recipient,
            validated: 0,
            approvalCount: 0
        });
        paymentRequests.push(newPaymentRequest);
    }
    
    function validatePaymentRequest(uint index) public onlyOwner {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        require(paymentRequest.validated == 0, "Already validated");
        paymentRequest.validated = 1;
    }
    
    function approvePaymentRequest(uint index) public {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        require(!(paymentRequest.validated == 0), "Payment needs to be validated by owner");
        require(!paymentRequest.approval[msg.sender],"You already approved");
        require(canApprove[msg.sender],"You have given your approval to the owner");
        
        //can move this to completePaymentRequest
        require(address(this).balance >= paymentRequest.amount, "Don't have enough credit in the contract");
        
        //vulnerablity : contributor trustOwner() ->Owner approvePaymentRequest()-> contributor revokeTrust() -> contributor approvePaymentRequest() 
        //this contributor can vote twice
        
        //can move this owner approval to the completePaymentRequest
        if(msg.sender == owner) {
            paymentRequest.approvalCount += ownerApprovalValue;
        }
        else{
            paymentRequest.approvalCount++;
        }
        paymentRequest.approval[msg.sender] = true;
        
    }
    
    function paymentRequestList() public view returns (string memory, uint, address, uint8, uint) {
        // uint j = 0;
        // while(j != paymentRequests.length) {
        //     return (paymentRequests[j].description, paymentRequests[j].amount, paymentRequests[j],recipient);
        // }
        return(paymentRequests[0].description, paymentRequests[0].amount, paymentRequests[0].recipient, paymentRequests[0].validated, paymentRequests[0].approvalCount);
    }
    
    // function completePaymentRequest(uint index) public onlyOwner {
    //     PaymentRequest memory paymentRequest = paymentRequests[index];
        
    //     paymentRequest.approvalCount += ownerApprovalValue;
        
    //     require(paymentRequest.approvalCount);
    // }
    
    function trustOwner() public onlyContributor {
        require(!trust[msg.sender]);
        trust[msg.sender] = true;
        canApprove[msg.sender] = false;
        ownerApprovalValue++;
    }
    
    function revokeTrust() public onlyContributor {
        require(trust[msg.sender]);
        canApprove[msg.sender] = true;
        ownerApprovalValue--;
    }
    
}
```

**<span style="color:red">Version-3</span>** (Some minor changes. No functionality difference. Upgraded to be compiled in 0.8.0)

```
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

contract NgoFundManagement {
    
    address owner;
    uint ownerApprovalValue;
    mapping(address => bool) contributor;
    mapping(address => bool) trust;
    mapping(address => bool) canApprove;
    mapping(uint => bool) completed;
    
    enum State {release, hold, spent};
    
    //can validate PaymentRequest with mapping
    uint contributorCount;
    // PaymentRequest[] private paymentRequests;
    uint numPaymentRequest;
    mapping (uint => PaymentRequest) paymentRequests;
    
    
    
    struct PaymentRequest {
        string description;
        uint amount;
        address payable recipient;
        // bool validated;
        uint8 validated;
        mapping(address => bool) approval;
        uint approvalCount;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner allowed");
        _;
    }
    
    modifier onlyContributor() {
        require(contributor[msg.sender], "Only contributors allowed");
        _;
    }
    
    //error handling = require, assert, revert
    constructor() {
        owner = msg.sender;
        canApprove[owner] = true;
    }
    
    function contribute() public payable {
        contributor[msg.sender] = true;
        canApprove[msg.sender] = true;
        contributorCount++;
    }
    
    function requestPayment(string memory _description, uint _amount, address payable _recipient) public {
        // PaymentRequest memory newPaymentRequest = PaymentRequest({
        //     description: _description,
        //     amount: _amount,
        //     recipient: _recipient,
        //     validated: 0,
        //     approvalCount: 0
        // });
        // paymentRequests.push(newPaymentRequest);
        PaymentRequest storage newPR = paymentRequests[numPaymentRequest++];
        newPR.description = _description;
        newPR.amount = _amount;
        newPR.recipient = _recipient;
    }
    
    function validatePaymentRequest(uint index) public onlyOwner {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        require(paymentRequest.validated == 0, "Already validated");
        paymentRequest.validated = 1;
    }
    
    function approvePaymentRequest(uint index) public {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        require(!completed[index], "This request has already been processed");
        require(!(paymentRequest.validated == 0), "Payment needs to be validated by owner");
        require(!paymentRequest.approval[msg.sender],"You already approved");
        require(canApprove[msg.sender],"You have given your approval to the owner");
        
        //can move this to completePaymentRequest
        
        //vulnerablity : contributor trustOwner() ->Owner approvePaymentRequest()-> contributor revokeTrust() -> contributor approvePaymentRequest() 
        //this contributor can vote twice
        
        //can move this owner approval to the completePaymentRequest
        paymentRequest.approvalCount++;
        paymentRequest.approval[msg.sender] = true;
    }

    function paymentRequestLength() public view returns(uint) {
        return(numPaymentRequest);
    }
    
    function viewPaymentRequest(uint index) public view returns (string memory des, uint amt, address rec, uint8 valid, uint appCnt) {
        return (paymentRequests[index].description, paymentRequests[index].amount, paymentRequests[index].recipient, paymentRequests[index].validated, paymentRequests[index].approvalCount);
    }
    
    function completePaymentRequest(uint index) public onlyOwner {
        PaymentRequest storage paymentRequest = paymentRequests[index];
        
        paymentRequest.approvalCount += ownerApprovalValue;
        
        require(paymentRequest.approvalCount >= (contributorCount / 2), "Not enough approval");
        require(address(this).balance >= paymentRequest.amount, "Not enough balance");
        require(!completed[index], "paymentRequest already processed");
        
        paymentRequest.recipient.transfer(paymentRequest.amount);
    }
    
    function trustOwner() public onlyContributor {
        require(!trust[msg.sender]);
        trust[msg.sender] = true;
        canApprove[msg.sender] = false;
        ownerApprovalValue++;
    }
    
    function revokeTrust() public onlyContributor {
        require(trust[msg.sender]);
        canApprove[msg.sender] = true;
        ownerApprovalValue--;
    }
    
}
```