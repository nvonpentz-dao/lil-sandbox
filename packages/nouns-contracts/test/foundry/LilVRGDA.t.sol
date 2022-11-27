// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { LilVRGDA } from "../../contracts/LilVRGDA.sol";
import { DeployUtils } from "./helpers/DeployUtils.sol";

contract LilVRGDATest is DeployUtils {
    function testConstructor() public {
        LilVRGDA vrgda = new LilVRGDA(0, address(0), address(0));
    }
}
