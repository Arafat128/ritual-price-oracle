// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {PriceOracle} from "../src/PriceOracle.sol";

contract DeployScript is Script {
    function run() external returns (PriceOracle oracle) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        oracle = new PriceOracle();
        console2.log("PriceOracle deployed at:", address(oracle));

        vm.stopBroadcast();
    }
}