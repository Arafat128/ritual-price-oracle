// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {RitualAddresses} from "./RitualAddresses.sol";
import {IRitualWallet} from "./interfaces/IRitualWallet.sol";
import {ITEEServiceRegistry} from "./interfaces/ITEEServiceRegistry.sol";

/// @title PriceOracle
/// @notice Fetches live ETH/USD from CoinGecko via Ritual HTTP precompile, parses with JQ on-chain.
/// @dev HTTP (short-running async) + JQ (sync) in a single transaction.
contract PriceOracle {
    uint256 public constant DEFAULT_TTL = 100;
    uint256 public constant DEFAULT_LOCK_BLOCKS = 5000;

    string public latestPrice;
    uint256 public lastUpdatedBlock;
    address public lastExecutor;

    event PriceUpdated(string price, uint256 blockNumber, address executor);
    event WalletFunded(address indexed funder, uint256 amount, uint256 lockBlocks);
    event FetchFailed(string reason);

    /// @notice Deposit RITUAL into RitualWallet for the caller (required before async HTTP calls).
    function fundWallet() external payable {
        require(msg.value > 0, "zero deposit");
        IRitualWallet(RitualAddresses.RITUAL_WALLET).deposit{value: msg.value}(DEFAULT_LOCK_BLOCKS);
        emit WalletFunded(msg.sender, msg.value, DEFAULT_LOCK_BLOCKS);
    }

    /// @notice Pick an HTTP executor from TEEServiceRegistry and fetch ETH/USD.
    function fetchETHPrice() external returns (string memory price) {
        address executor = _pickHttpExecutor();
        return _fetchETHPrice(executor);
    }

    /// @notice Fetch ETH/USD using a specific TEE executor address.
    function fetchETHPriceWithExecutor(address executor) external returns (string memory price) {
        require(executor != address(0), "zero executor");
        return _fetchETHPrice(executor);
    }

    function _fetchETHPrice(address executor) internal returns (string memory price) {
        bytes memory body = _httpGet(executor, RitualAddresses.COINGECKO_ETH_USD_URL);
        price = _jqString(RitualAddresses.JQ_ETH_USD_QUERY, string(body));

        latestPrice = price;
        lastUpdatedBlock = block.number;
        lastExecutor = executor;

        emit PriceUpdated(price, block.number, executor);
    }

    function _pickHttpExecutor() internal view returns (address executor) {
        ITEEServiceRegistry registry = ITEEServiceRegistry(RitualAddresses.TEE_SERVICE_REGISTRY);

        (address teeAddress, bool found) = registry.pickServiceByCapability(
            RitualAddresses.HTTP_CALL_CAPABILITY,
            true,
            uint256(keccak256(abi.encodePacked(block.number, block.timestamp, address(this)))),
            10
        );
        if (found) return teeAddress;

        uint256 count = registry.getIndexedServiceCountByCapability(RitualAddresses.HTTP_CALL_CAPABILITY);
        require(count > 0, "no HTTP executor");

        return registry.getIndexedServiceByCapabilityAt(RitualAddresses.HTTP_CALL_CAPABILITY, 0);
    }

    function _httpGet(address executor, string memory url) internal returns (bytes memory body) {
        bytes memory input = abi.encode(
            executor,
            new bytes[](0),
            DEFAULT_TTL,
            new bytes[](0),
            bytes(""),
            url,
            RitualAddresses.HTTP_GET,
            new string[](0),
            new string[](0),
            bytes(""),
            uint256(0),
            uint8(0),
            false
        );

        (bool success, bytes memory rawOutput) = RitualAddresses.HTTP_PRECOMPILE.call(input);
        if (!success) {
            emit FetchFailed("HTTP precompile call failed");
            revert("HTTP precompile call failed");
        }

        (, bytes memory actualOutput) = abi.decode(rawOutput, (bytes, bytes));

        uint16 statusCode;
        string memory errorMessage;
        (statusCode,,, body, errorMessage) =
            abi.decode(actualOutput, (uint16, string[], string[], bytes, string));

        if (bytes(errorMessage).length > 0) {
            emit FetchFailed(errorMessage);
            revert(errorMessage);
        }

        if (statusCode != 200) {
            string memory reason = string(abi.encodePacked("HTTP status ", _uintToString(statusCode)));
            emit FetchFailed(reason);
            revert(reason);
        }
    }

    function _jqString(string memory query, string memory jsonInput) internal returns (string memory result) {
        (bool ok, bytes memory raw) = RitualAddresses.JQ_PRECOMPILE.staticcall(
            abi.encode(query, jsonInput, RitualAddresses.JQ_OUTPUT_STRING)
        );

        if (!ok || raw.length == 0) {
            emit FetchFailed("JQ query failed");
            revert("JQ query failed");
        }

        return _decodeJQString(raw);
    }

    /// @dev JQ string output uses double-indirection encoding.
    function _decodeJQString(bytes memory raw) internal pure returns (string memory) {
        require(raw.length >= 96, "JQ output too short");
        uint256 strLen;
        assembly {
            strLen := mload(add(raw, 96))
        }
        bytes memory result = new bytes(strLen);
        for (uint256 i = 0; i < strLen; i++) {
            result[i] = raw[96 + i];
        }
        return string(result);
    }

    function _uintToString(uint16 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    receive() external payable {}
}