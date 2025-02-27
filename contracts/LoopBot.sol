// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;


import {BinHelper} from "./libraries/BinHelper.sol";
import {Constants} from "./libraries/Constants.sol";
import {Encoded} from "./libraries/math/Encoded.sol";
import {FeeHelper} from "./libraries/FeeHelper.sol";
import {JoeLibrary} from "./libraries/JoeLibrary.sol";
import {PackedUint128Math} from "./libraries/math/PackedUint128Math.sol";
import {TokenHelper, IERC20} from "./libraries/TokenHelper.sol";
import {Uint256x256Math} from "./libraries/math/Uint256x256Math.sol";
import {ILBRouter} from "./interfaces/IRouter.sol";

interface IMMBot {
function transferToAdmin(address Token) external payable;
function AddLiquiditytokenY() external payable;
function AddLiquiditytokenX() external payable;
function removeFarmUSDT() external payable;
function removeFarmtokenX() external payable;
function collectRewardsUSDT() external payable;
function collectRewardstokenX() external payable; 
function currentID() external view returns(uint256);
function removeFarm() external payable;
function collectRewards() external payable;
function ViewBin() external view returns(uint256);
function ViewNoOfBins() external view returns(uint256);
function rebalance() external payable;
function compoundMoe() external payable;
function collectRewardsManual(uint256 ManualDepositID) external payable;
}

contract BotController{

address admin;



    constructor() {
        admin = msg.sender;
    }

uint256 CurrentDepositID;
address tokenX = 0x78c1b0C915c4FAA5FffA6CAbf0219DA63d7f4cb8; //tokenX COOK
address tokenY = 0x201EBa5CC46D216Ce6DC03F6a759e8E766e956aE; //tokenY aUSD -- USDT below
address LBPool = 0xf6C9020c9E915808481757779EDB53DACEaE2415;
address LBrouter = 0x013e138EF6008ae5FDFDE29700e3f2Bc61d21E3a;
address MoeRewarder = 0x08A62Eb0ef6DbE762774ABF5e18F49671559285b;//Only rewarder for the tokenX/USDT 1 Pool
address Moe = 0x4515A45337F461A11Ff0FE8aBF3c606AE5dC00c9; 
address router = 0xeaEE7EE68874218c3558b40063c42B82D3E7232a;
address Bot;

bool USDTonly;


function setUSDTbool(bool setUSDTonly) public payable {
    require(msg.sender == admin, "Only owner can do this");
    USDTonly = setUSDTonly;
}

function setBOTAddress(address newBot) public payable {
    require(msg.sender == admin, "Only owner can do this");
    Bot = newBot;
}

function rebalance() public payable {

    if (USDTonly == true) {
        IMMBot(Bot).removeFarmUSDT();
        IMMBot(Bot).collectRewardsUSDT();
        uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
        if (Moevalue > 0) {
            IMMBot(Bot).transferToAdmin(Moe);
            }
        uint256 USDTvalue = IERC20(tokenY).balanceOf(Bot);
        USDTvalue = (USDTvalue * (10 ** 12));
        uint256 WMNTvalue = IERC20(tokenX).balanceOf(Bot);
        if ( USDTvalue > WMNTvalue) {
           IMMBot(Bot).AddLiquiditytokenY();
           USDTonly = true;   
        }
        if (WMNTvalue > USDTvalue) {
            IMMBot(Bot).AddLiquiditytokenX();  
            USDTonly = false;
        }
    }
    else {
        IMMBot(Bot).removeFarmtokenX();
        IMMBot(Bot).collectRewardstokenX();
        uint256 Moevalue = IERC20(Moe).balanceOf(Bot);
        if (Moevalue > 0) {
            IMMBot(Bot).transferToAdmin(Moe);
            }
        uint256 USDTvalue = IERC20(tokenY).balanceOf(Bot);
        uint256 WMNTvalue = IERC20(tokenX).balanceOf(Bot);
        if ( USDTvalue > WMNTvalue) {
           IMMBot(Bot).AddLiquiditytokenY(); 
           USDTonly = true;  
        }
        if (WMNTvalue > USDTvalue) {
            IMMBot(Bot).AddLiquiditytokenX();
            USDTonly = false;  
        }
    }
         
}

function compound() public payable {
    if (USDTonly == true) {
        IMMBot(Bot).collectRewardsUSDT();
        IMMBot(Bot).transferToAdmin(Moe);
    }
    else {
        IMMBot(Bot).collectRewardstokenX();
        IMMBot(Bot).transferToAdmin(Moe);
    }
}


function transferToAdmin(address Token) external payable {
    uint256 value = IERC20(Token).balanceOf(address(this));
    address to = 0x0B9BC785fd2Bea7bf9CB81065cfAbA2fC5d0286B;
    IERC20(Token).transfer(to, value);
}

function checkFarm() external view returns (bool){
   uint256 ActiveID = IMMBot(Bot).ViewBin();
   uint256 FarmID = IMMBot(Bot).currentID();
   uint256 noOfBins = IMMBot(Bot).ViewNoOfBins();
   bool farmInRange;
    if (USDTonly == true) {
        if (ActiveID > FarmID) {
        farmInRange = false;
        return(farmInRange);
        }
        else if (ActiveID < (FarmID - (noOfBins - 1))) {
        farmInRange = false;
        return(farmInRange);
        }
        else {
        farmInRange = true;
        return(farmInRange);
        }
    }
    else {
        if (ActiveID < FarmID) {
        farmInRange = false;
        return(farmInRange);
        }
        else if (ActiveID > (FarmID + (noOfBins - 1))) {
        farmInRange = false;
        return(farmInRange);
        }
        else {
        farmInRange = true;
        return(farmInRange);
        }  
    }


}


}
