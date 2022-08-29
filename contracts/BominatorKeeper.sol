// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

interface IBotMinator {
    function checkSwapParams() external view returns (bool, bool, uint);
    
}

contract BominatorKeeper is KeeperCompatibleInterface{

    address public vaultAddr;
    address public owner;
    uint256 lastRunDay = 0;
    bytes32 public config;
  

    constructor(
    //    bytes32 _config, // optional
       address _vault0
    ) {
        owner = msg.sender;
        vaultAddr = _vault0;
        // config = _config;
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
        (bool shouldRunRoute1 , bool shouldRunRoute2 , uint amountToTrade)  = IBotMinator(vaultAddr).checkSwapParams();
        upkeepNeeded = shouldRunRoute1  || shouldRunRoute2;
        performData = abi.encodePacked(shouldRunRoute1,shouldRunRoute2,amountToTrade);
    }
    
    function performUpkeep(bytes calldata performData) external override {

        uint8 shouldRunRoute1 = uint8(performData[0]);
        uint8 shouldRunRoute2 = uint8(performData[1]);
        bytes memory memcopy = performData; 
        uint256 amount;
        assembly {
            amount := mload(add(memcopy,0x22))  
        }
        bool success;
        if(shouldRunRoute1 == 1){
            (success,) = vaultAddr.call(abi.encodeWithSignature("HedgerRoute1(amountIn)", amount));
        }else if (shouldRunRoute2 == 1){
            (success,) = vaultAddr.call(abi.encodeWithSignature("HedgerRoute2(amountIn)", amount));
        }else{
            revert ("error in performing upkeep");
        }

        require(success,"Transaction Failed");
    }
}
