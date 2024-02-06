// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimingContract {
    struct RefundRequest {
        uint256 timestamp;
        bool claimed;
    }

    IERC20 public token;
    uint256 public refundDeadline;
    address public admin;
    mapping(address => RefundRequest) public refundRequests;
    address[] public refundRequestList; // Store the list of refund requests
    mapping(address => uint256) public balances;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(IERC20 _token) {
        token = _token;
        admin = msg.sender; // Set the deployer as the initial admin
    }

    function setRefundDeadline(uint256 _refundDeadline) external onlyAdmin {
        refundDeadline = _refundDeadline;
    }

    function requestRefund() public {
        require(block.timestamp <= refundDeadline, "Refund deadline has passed.");
        require(refundRequests[msg.sender].timestamp == 0, "Refund already requested.");

        refundRequests[msg.sender] = RefundRequest({
        timestamp: block.timestamp,
        claimed: false
        });

        refundRequestList.push(msg.sender); 
    }


    function removeRefundRequest(address user) public onlyAdmin {
        require(block.timestamp > refundDeadline, "Refund deadline has not passed yet.");
        require(!refundRequests[user].claimed, "User has already claimed tokens.");

        // Remove the user from the refund request list
        for (uint i = 0; i < refundRequestList.length; i++) {
            if (refundRequestList[i] == user) {
                refundRequestList[i] = refundRequestList[refundRequestList.length - 1];
                refundRequestList.pop();
                break;
            }
        }

        delete refundRequests[user];
    }

    function exportRefundRequestList() public onlyAdmin view returns (address[] memory) {
        return refundRequestList;
    }


    function claimTokens(uint amount) public {
        require(refundRequests[msg.sender].timestamp > 0, "No refund request found.");
        require(!refundRequests[msg.sender].claimed, "Tokens already claimed.");

        refundRequests[msg.sender].claimed = true;

        // Remove the user from the refund request list when they claim tokens.
        for (uint i = 0; i < refundRequestList.length; i++) {
            if (refundRequestList[i] == msg.sender) {
                refundRequestList[i] = refundRequestList[refundRequestList.length - 1];
                refundRequestList.pop();
                break;
            }
        }

        token.transfer(msg.sender, amount);
        balances[msg.sender] -= amount;
    }

    function withdrawUnclaimableTokens(address[] calldata excludedWallets) public onlyAdmin {
        require(block.timestamp > refundDeadline, "Refund deadline has not passed yet.");

        // Calculate the unclaimable amount of tokens.
        uint256 unclaimableAmount = 0;
        for (uint i = 0; i < excludedWallets.length; i++) {
            unclaimableAmount += balances[excludedWallets[i]];
        }

        // Transfer unclaimable tokens to the project's address
        token.transfer(admin, unclaimableAmount);
    }

    function deposit(uint amount) public {
        // Update the user's balance
        balances[msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function balanceOfToken(address user) public view returns (uint256) {
        return token.balanceOf(address(user));
    }
}


