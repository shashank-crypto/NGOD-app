// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

contract NgoFundManagement {
    
    address owner;
    uint ownerApprovalValue;
    mapping(address => bool) contributor;
    mapping(address => bool) trust;
    mapping(address => bool) canApprove;
    mapping(uint => bool) completed;
    
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