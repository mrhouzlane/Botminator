// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

contract BominatorKeeper is KeeperCompatibleInterface{

    DummyContract public vault1;
    DummyContract public vault2;
    address public owner;
    uint256 lastRunDay = 0;
    bytes32 public config;
    bool public dummyCalldata;

    constructor(
       bytes32 _config, // optional
       address _vault1,
       address _vault2
    ) {
        owner = msg.sender;
        vault1 = DummyContract(_vault1);
        vault2 = DummyContract(_vault2);
        config = _config;
    }

    function setConfig(bytes32 _config) external {
        require ( msg.sender == owner , "caller is not owner");
        config = _config; // optional
    }

    function checkUpkeep(bytes calldata checkData)
        external
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        bool shouldRunVault1 = vault1.shouldCall();
        bool shouldRunVault2 = vault2.shouldCall();
        upkeepNeeded = shouldRunVault1  || shouldRunVault2;
        dummyCalldata = true;
        performData = abi.encodePacked(shouldRunVault1,shouldRunVault2);
    }
    
    function performUpkeep(bytes calldata performData) external override {

        uint8 shouldRunVault1 = uint8(performData[0]);
        uint8 shouldRunVault2 = uint8(performData[1]);
        
        if(shouldRunVault1 == 1){
            //call vault contract1
        }else if (shouldRunVault2 == 1){
            //call vault contract2
        }else{
            revert ("error in performing upkeep");
        }
    }

    // READER FUNCTIONS TO TEST AND VIEW DATA
    // function dummyCheck(bytes calldata b) external view returns (uint8 shouldRunVault1, uint8 shouldRunVault2){
    //     assembly {
    //         shouldRunVault1 := calldataload(add(b.offset,5))
    //         shouldRunVault2 := calldataload(add(b.offset,6))
    //     }
    // }

    //change this to internal
    function _checkCallData() public view returns (bytes memory) {

        // can add more variables and encode them all together

        bool shouldRunVault1 = vault1.shouldCall();
        bool shouldRunVault2 = vault2.shouldCall();

        return abi.encodePacked(shouldRunVault1,shouldRunVault2);
    }
}

contract DummyContract {
    uint256 public amount1;
    uint256 public amount2;
    bool public shouldRun;

    constructor(bool _shouldRun){
        shouldRun = _shouldRun;
    }

    function getAmounts() external view returns (uint256, uint256, bool) {
        return (12,12,shouldRun);
    }
    function setAmounts(bytes32 performUpdate) external {
        amount1 = 1 ;
        amount2 = 2 ; 
        shouldRun = !shouldRun;
    }
    function shouldCall() public view returns (bool){
        return shouldRun;
    }   
}
