// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";



contract APIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    string public test;
    bytes32 private jobId;
    uint256 private fee;

    mapping(bytes32 => string) public apiResponses; 

    string public teamNameFromAPI;
    string public userSelectedTeamName;

    uint public optionAUsers;
    uint public optionBUsers;

    mapping(address => uint256) public userBetOptionA;  
    mapping(address => uint256) public userBetOptionB;  

    address[] public usersForOptionA;
    address[] public usersForOptionB;

    uint256 public totalTokens = 10 * 10**18;

    mapping(address => uint8) public userChoices;

    event RequestVolume(bytes32 indexed requestId, string _test);
    event TeamNameValidation(bool isValid, string userInput, string correctAnswer);
    event TokenDistribution(address indexed user, uint256 amount);
    // uint256 public deploymentTime;

    

    constructor() ConfirmedOwner(msg.sender){
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "7d80a6386ef543a3abb52817f6707e3d"; // Example Job ID
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0.1 LINK (Varies by network and job)
    }

    /**
     * Request data from the dynamic API based on the provided URL pattern, parameters, and path.
     * This function is now flexible to handle dynamic URLs and paths.
     */
    function requestVolumeData(
        string memory apiUrl, 
        string memory apiKey, 
        string memory matchInfoValue,
        string memory path 
    ) public returns (bytes32 requestId) {

        string memory finalApiUrl = string(abi.encodePacked(apiUrl, "?apikey=", apiKey, "&id=", matchInfoValue));

        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req._add("get", finalApiUrl);

        req._add("path", path); 

        return _sendChainlinkRequest(req, fee);
    }

    /**
     * Handle the response from the API and store it.
     * The requestId is used to map the response to the specific request.
     */
    function fulfill(bytes32 _requestId, string memory _response) public recordChainlinkFulfillment(_requestId) {
        apiResponses[_requestId] = _response; // Store the response for the corresponding requestId

        emit RequestVolume(_requestId, _response);
        
         if (_requestId == jobId) {
            teamNameFromAPI = _response;  
            validateTeamSelection();
        }
    }

    /**
     * Function to allow the user to select between two teams (Option A or Option B)
     */
    function setUserSelectedTeam(uint8 choice, uint256 betAmount) public {
        require(userChoices[msg.sender] == 0, "You have already selected an option.");
        
        if (choice == 1) {
            userSelectedTeamName = "Option A";
            optionAUsers += 1;
            usersForOptionA.push(msg.sender);
            userBetOptionA[msg.sender] = betAmount; 
        } else if (choice == 2) {
            userSelectedTeamName = "Option B";
            optionBUsers += 1;
            usersForOptionB.push(msg.sender);
            userBetOptionB[msg.sender] = betAmount;  
        } else {
            revert("Invalid choice. Please choose 1 for Option A or 2 for Option B.");
        }

        userChoices[msg.sender] = choice;

        validateTeamSelection();
    }

    /**
     * Function to compare the user's selection with the API response
     */
    function validateTeamSelection() internal {
        bool isValid = keccak256(abi.encodePacked(teamNameFromAPI)) == keccak256(abi.encodePacked(userSelectedTeamName));
        emit TeamNameValidation(isValid, userSelectedTeamName, teamNameFromAPI);
        
        if (isValid) {
            distributeTokens(true);  
        } else {
            distributeTokens(false); 
        }
    }

    /**
     * Function to distribute tokens based on the number of users per option and reward calculation
     */
    function distributeTokens(bool isCorrectPrediction) internal {
        uint256 totalBetOptionA = 0;
        uint256 totalBetOptionB = 0;

        for (uint i = 0; i < usersForOptionA.length; i++) {
            totalBetOptionA += userBetOptionA[usersForOptionA[i]];
        }

        for (uint i = 0; i < usersForOptionB.length; i++) {
            totalBetOptionB += userBetOptionB[usersForOptionB[i]];
        }

        uint256 totalBetOnAllOptions = totalBetOptionA + totalBetOptionB;

        uint256 pricePerOptionA = (totalBetOptionA * totalTokens) / totalBetOnAllOptions;
        uint256 pricePerOptionB = (totalBetOptionB * totalTokens) / totalBetOnAllOptions;

        if (isCorrectPrediction) {
            for (uint i = 0; i < usersForOptionA.length; i++) {
                address user = usersForOptionA[i];
                uint256 userBet = userBetOptionA[user];
                uint256 userReward = (userBet * pricePerOptionA) / totalBetOptionA;
                transferTokens(user, userReward); 
            }

            for (uint i = 0; i < usersForOptionB.length; i++) {
                address user = usersForOptionB[i];
                uint256 userBet = userBetOptionB[user];
                uint256 userReward = (userBet * pricePerOptionB) / totalBetOptionB;
                transferTokens(user, userReward); 
            }
        } else {
            uint256 totalPoolForLosingOption = totalTokens - pricePerOptionA - pricePerOptionB;

            if (optionAUsers < optionBUsers) {
                for (uint i = 0; i < usersForOptionB.length; i++) {
                    address user = usersForOptionB[i];
                    uint256 userBet = userBetOptionB[user];
                    uint256 userReward = (userBet * totalPoolForLosingOption) / totalBetOptionB;
                    transferTokens(user, userReward);
                }
            }

            if (optionBUsers < optionAUsers) {
                for (uint i = 0; i < usersForOptionA.length; i++) {
                    address user = usersForOptionA[i];
                    uint256 userBet = userBetOptionA[user];
                    uint256 userReward = (userBet * totalPoolForLosingOption) / totalBetOptionA;
                    transferTokens(user, userReward);
                }
            }
        }
    }

    /**
     * Function to transfer tokens to the user
     */
    function transferTokens(address user, uint256 amount) internal {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(link.transfer(user, amount), "Unable to transfer tokens");
        emit TokenDistribution(user, amount);
    }

    /**
     * Allow the owner to withdraw LINK tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer LINK");
    }
}