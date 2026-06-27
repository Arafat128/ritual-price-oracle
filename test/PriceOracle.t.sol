// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PriceOracle} from "../src/PriceOracle.sol";
import {RitualAddresses} from "../src/RitualAddresses.sol";

contract PriceOracleTest is Test {
    PriceOracle internal oracle;

    function setUp() public {
        oracle = new PriceOracle();
    }

    function test_mockHttpAndJq() public {
        bytes memory mockBody = bytes('{"ethereum":{"usd":2456.78}}');
        bytes memory mockHttpOutput = abi.encode(uint16(200), new string[](0), new string[](0), mockBody, "");
        bytes memory mockRaw = abi.encode(bytes(""), mockHttpOutput);

        vm.mockCall(RitualAddresses.HTTP_PRECOMPILE, bytes(""), mockRaw);

        string memory jqInput = '{"ethereum":{"usd":2456.78}}';
        bytes memory jqRaw = _encodeJqStringOutput("2456.78");
        bytes memory jqCalldata =
            abi.encode(RitualAddresses.JQ_ETH_USD_QUERY, jqInput, RitualAddresses.JQ_OUTPUT_STRING);

        vm.mockCall(RitualAddresses.JQ_PRECOMPILE, jqCalldata, jqRaw);

        string memory price = oracle.fetchETHPriceWithExecutor(address(0xBEEF));

        assertEq(price, "2456.78");
        assertEq(oracle.latestPrice(), "2456.78");
        assertEq(oracle.lastExecutor(), address(0xBEEF));
    }

    function test_revertsOnHttpError() public {
        bytes memory mockHttpOutput = abi.encode(uint16(500), new string[](0), new string[](0), bytes(""), "executor error");
        bytes memory mockRaw = abi.encode(bytes(""), mockHttpOutput);

        vm.mockCall(RitualAddresses.HTTP_PRECOMPILE, bytes(""), mockRaw);

        vm.expectRevert("executor error");
        oracle.fetchETHPriceWithExecutor(address(0xBEEF));
    }

    /// @dev Mimics JQ OutString double-indirection layout for tests.
    function _encodeJqStringOutput(string memory value) internal pure returns (bytes memory) {
        bytes memory strBytes = bytes(value);
        uint256 len = strBytes.length;

        bytes memory raw = new bytes(96 + len);
        assembly {
            mstore(add(raw, 96), len)
        }
        for (uint256 i = 0; i < len; i++) {
            raw[96 + i] = strBytes[i];
        }
        return raw;
    }
}