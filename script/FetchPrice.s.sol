// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {PriceOracle} from "../src/PriceOracle.sol";

/// @notice Triggers fetchETHPrice() on the deployed oracle.
/// @dev Set ORACLE_ADDRESS in .env. Wait 30-60s for async HTTP settlement.
contract FetchPriceScript is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address payable oracle = payable(vm.envAddress("ORACLE_ADDRESS"));

        vm.startBroadcast(deployerKey);

        string memory price = PriceOracle(oracle).fetchETHPrice();
        console2.log("Fetched ETH/USD price:", price);

        vm.stopBroadcast();
    }
}