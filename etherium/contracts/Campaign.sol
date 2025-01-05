// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = address(new Campaign(minimum, msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    mapping(uint => mapping(address => bool)) public approvals;

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    constructor(uint minimum, address creator) {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution, "Contribution must be at least the minimum amount");

        if (!approvers[msg.sender]) {
            approvers[msg.sender] = true;
            approversCount++;
        }
    }

    function createRequest(string memory description, uint value, address payable recipient) public restricted {
        require(value <= address(this).balance, "Insufficient balance in the campaign");
        require(recipient != address(0), "Recipient address cannot be zero");

        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender], "Only contributors can approve requests");
        require(!approvals[index][msg.sender], "You have already approved this request");

        approvals[index][msg.sender] = true;
        requests[index].approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(request.approvalCount > (approversCount / 2), "Majority approval required");
        require(!request.complete, "Request already completed");

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}