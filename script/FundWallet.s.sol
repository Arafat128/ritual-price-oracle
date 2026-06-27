// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

/// @notice Deposits RITUAL into RitualWallet for the deployer EOA.
/// @dev Async HTTP fees are charged to the EOA, not the oracle contract.
contract FundWalletScript is Script {
    address constant RITUAL_WALLET = 0x532F0dF0896F353d8C3DD8cc134e8129DA2a3948;
    uint256 constant LOCK_BLOCKS = 5000;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        uint256 amount = vm.envOr("FUND_AMOUNT", uint256(0.05 ether));

        vm.startBroadcast(deployerKey);

        (bool ok,) = RITUAL_WALLET.call{value: amount}(abi.encodeWithSignature("deposit(uint256)", LOCK_BLOCKS));
        require(ok, "RitualWallet deposit failed");

        console2.log("Funded deployer RitualWallet with:", amount, "wei");

        vm.stopBroadcast();
    }
}