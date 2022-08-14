// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4; //fixed solidity version 

//block Timestamp should not be used 
// be careful about division 


// Import this file to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//@title Dynamic NFT chaching with Price of PAIR
//@author RHOUZLANE Mehdi

contract MoodyLink is Ownable, VRFConsumerBaseV2, ERC721  {

    address public winner;
    address[] public participants;
    mapping(address => bool) public isWhitelisted ; 
    mapping(address => uint256) public addressToTicket; 
    mapping(uint256 => address) winnerToAddress ;

    enum LotterySteps {
        notStarted,
        Initialized, 
        Started,
        Finished
    }

    LotterySteps public status ;


    //------------------------------------------------------CHAINLINK PART--------------------------------------------------------------------------///

    
    //---RINKEBY----
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 public s_subscriptionId;

    
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    
    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    
    uint32 numWords =  2;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address public s_owner;

    constructor(uint64 subscriptionId) ERC721("SaintETH", "STH") VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;

    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    ///------------------------------------------------------GIVEAWAY--------------------------------------------------------------------------///


    //@notice Enters lottery by paying 0.1 ethers 
    function enterLottery() external payable{
        require(msg.value >= 0.1 ether, "Not enough"); //small revert text to consume less gas
        status = LotterySteps.Initialized;
        isWhitelisted[msg.sender] = true;
        participants.push(payable(msg.sender));

        status = LotterySteps.Initialized;

    }

   

    //@notice Start the Lottery
    function startLottery() public onlyOwner {
        //require(status == LotterySteps.Initialized);
        require(participants.length >= 3); // for testing purposes we set 3 to test with 3 accounts; 
        status = LotterySteps.Started;

        for (uint i = 0 ; i < participants.length ; i++){
            addressToTicket[participants[i]] = i; 
        }

    }

    

    // @notice mint token without paying for authorization gas fees 
    function selectWinner(address from, uint256 tokenId) public {
        require(status == LotterySteps.Started);
        for (uint i = 1 ; i < participants.length ; i ++ ){
            if (addressToTicket[participants[i]] ==  s_randomWords[0] % participants.length) {
                winner = winnerToAddress[s_randomWords[0]];
            }
        }

        safeTransferFrom(from, winner, tokenId);

        status = LotterySteps.Finished ;

    }

    
  





    



   
}