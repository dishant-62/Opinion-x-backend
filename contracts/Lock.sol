
// pragma solidity ^0.8.7;

// import {Chainlink, ChainlinkClient} from "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
// import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
// import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

// /**
//  * Request testnet LINK and ETH here: https://faucets.chain.link/
//  * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
//  */

// /**
//  * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
//  * THIS EXAMPLE USES UN-AUDITED CODE.
//  * DO NOT USE THIS CODE IN PRODUCTION.
//  */

// contract APIConsumer is ChainlinkClient, ConfirmedOwner {
//     using Chainlink for Chainlink.Request;

//     uint256 public volume;
//     bytes32 private jobId;
//     uint256 private fee;

//     event RequestVolume(bytes32 indexed requestId, uint256 volume);

//     /**
//      * @notice Initialize the link token and target oracle
//      *
//      * Sepolia Testnet details:
//      * Link Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789
//      * Oracle: 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD (Chainlink DevRel)
//      * jobId: ca98366cc7314957b8c012c72f05aeeb
//      *
//      */
//     constructor() ConfirmedOwner(msg.sender) {
//         _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
//         _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
//         jobId = "ca98366cc7314957b8c012c72f05aeeb";
//         fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
//     }

//     /**
//      * Create a Chainlink request to retrieve API response, find the target
//      * data, then multiply by 1000000000000000000 (to remove decimal places from data).
//      */
//     function requestVolumeData() public returns (bytes32 requestId) {
//         Chainlink.Request memory req = _buildChainlinkRequest(
//             jobId,
//             address(this),
//             this.fulfill.selector
//         );

//         // Set the URL to perform the GET request on
//         req._add(
//             "get",
//             "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
//         );

//         // Set the path to find the desired data in the API response, where the response format is:
//         // {"RAW":
//         //   {"ETH":
//         //    {"USD":
//         //     {
//         //      "VOLUME24HOUR": xxx.xxx,
//         //     }
//         //    }
//         //   }
//         //  }
//         // request.add("path", "RAW.ETH.USD.VOLUME24HOUR"); // Chainlink nodes prior to 1.0.0 support this format
//         req._add("path", "RAW,ETH,USD,VOLUME24HOUR"); // Chainlink nodes 1.0.0 and later support this format

//         // Multiply the result by 1000000000000000000 to remove decimals
//         int256 timesAmount = 10 ** 18;
//         req._addInt("times", timesAmount);

//         // Sends the request
//         return _sendChainlinkRequest(req, fee);
//     }

//     /**
//      * Receive the response in the form of uint256
//      */
//     function fulfill(
//         bytes32 _requestId,
//         uint256 _volume
//     ) public recordChainlinkFulfillment(_requestId) {
//         emit RequestVolume(_requestId, _volume);
//         volume = _volume;
//     }

//     /**
//      * Allow withdraw of Link tokens from the contract
//      */
//     function withdrawLink() public onlyOwner {
//         LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
//         require(
//             link.transfer(msg.sender, link.balanceOf(address(this))),
//             "Unable to transfer"
//         );
//     }
//     // contract SumCalculator {
  
//     function add(uint256 num1, uint256 num2) public pure returns (uint256) {
//         return num1 + num2;
//     }

// }


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
        jobId = "7d80a6386ef543a3abb52817f6707e3b"; // Example Job ID
        // fee = (1 * LINK_DIVISIBILITY) / 10; // 0.1 LINK (Varies by network and job)
        fee = 0;
    }

    /**
     * Request data from the dynamic API based on the provided URL pattern, parameters, and path.
     * This function is now flexible to handle dynamic URLs and paths.
     */
    event DebugLog(string message, uint256 value);
    // function requestVolumeData(
    //     string memory apiUrl, 
    //     string memory apiKey, 
    //     string memory matchInfoValue,
    //     string memory path 
    // ) public returns (bytes32 requestId) {

    //     string memory finalApiUrl = string(abi.encodePacked(apiUrl, "?apikey=", apiKey, "&id=", matchInfoValue));
    //     emit DebugLog("Sending Chainlink request:", 0);
    //     emit DebugLog("Job ID:", uint256(jobId)); 
    //     emit DebugLog("Fee (in LINK):", fee);
    //     Chainlink.Request memory req = _buildChainlinkRequt(
    //         jobId,
    //         address(this),
    //         this.fulfill.selector
        

        
    //     );

    //     // req._add("get", finalApiUrl);

    //     // req._add("path", path); 
    //     req._add("get", "https://api.cricapi.com/v1/match_info?apikey=1a119783-131c-4e35-bfe2-00ba7f2d4f0e&id=43668401-454e-4844-995e-d591d1398cc7");

    //     req._add("path", "data,status");

    //     return _sendChainlinkRequest(req, fee);
    // }
    // function checkLinkBalance() public view returns (uint256) {
    // LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
    // return link.balanceOf(address(this));
// }
function fulfill(bytes32 _requestId, string memory _response) public recordChainlinkFulfillment(_requestId) {
    apiResponses[_requestId] = _response;

    if (bytes(_response).length == 0) {
        emit FulfillmentError(_requestId, "Empty response received from Chainlink");
        return;
    }

    emit RequestVolume(_requestId, _response);

    if (_requestId == jobId) {
        teamNameFromAPI = _response;
        validateTeamSelection();
    }
}

event FulfillmentError(bytes32 indexed requestId, string errorMessage);

function requestVolumeData(
    string memory apiUrl,
    string memory apiKey,
    string memory matchInfoValue,
    string memory path
) public returns (bytes32 requestId) {
    require(bytes(apiUrl).length > 0, "API URL is required");
    require(bytes(apiKey).length > 0, "API Key is required");
    require(bytes(matchInfoValue).length > 0, "Match Info Value is required");
    require(bytes(path).length > 0, "Path is required");

    string memory finalApiUrl = string(abi.encodePacked(apiUrl, "?apikey=", apiKey, "&id=", matchInfoValue));
    Chainlink.Request memory req = _buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

    req._add("get", finalApiUrl);
    req._add("path", path);

    requestId = _sendChainlinkRequest(req, fee);
    emit RequestSent(requestId, finalApiUrl, path);
    return requestId;
}

event RequestSent(bytes32 indexed requestId, string apiUrl, string path);
    /**
     * Handle the response from the API and store it.
     * The requestId is used to map the response to the specific request.
     */
    // function fulfill(bytes32 _requestId, string memory _response) public recordChainlinkFulfillment(_requestId) {
    //     apiResponses[_requestId] = _response; // Store the response for the corresponding requestId

    //     emit RequestVolume(_requestId, _response);
        
    //      if (_requestId == jobId) {
    //         teamNameFromAPI = _response;  
    //         validateTeamSelection();
    //     }
    // }
//     function fulfill(bytes32 _requestId, string memory _response) public recordChainlinkFulfillment(_requestId) {

//     emit DebugLog("fulfill function called with requestId:", uint256(_requestId));
//     emit DebugLog("Response received:", uint256(keccak256(abi.encodePacked(_response))));  


//     apiResponses[_requestId] = _response;

//     emit RequestVolume(_requestId, _response);

//     emit DebugLog("Stored response for requestId:", uint256(_requestId));

//     if (_requestId == jobId) {
//         emit DebugLog("Request ID matches job ID, processing response:", uint256(_requestId));

//         teamNameFromAPI = _response;  
 
//         emit DebugLog("Team name from API:", uint256(keccak256(abi.encodePacked(teamNameFromAPI)))); 
//         validateTeamSelection();
//     } else {
//         emit DebugLog("Request ID does not match job ID:", uint256(_requestId));
//     }
// }
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

    function returnInputString() public pure returns (string memory) {
    return "Rathi";
}

}

