// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Canonical Ritual Chain testnet addresses (chain ID 1979).
library RitualAddresses {
    address internal constant HTTP_PRECOMPILE = address(0x0801);
    address internal constant JQ_PRECOMPILE = address(0x0803);
    address internal constant RITUAL_WALLET = 0x532F0dF0896F353d8C3DD8cc134e8129DA2a3948;
    address internal constant TEE_SERVICE_REGISTRY = 0x9644e8562cE0Fe12b4deeC4163c064A8862Bf47F;
    address internal constant ASYNC_JOB_TRACKER = 0xC069FFCa0389f44eCA2C626e55491b0ab045AEF5;

    uint8 internal constant HTTP_CALL_CAPABILITY = 0;
    uint8 internal constant HTTP_GET = 1;
    uint8 internal constant JQ_OUTPUT_STRING = 2;

    string internal constant COINGECKO_ETH_USD_URL =
        "https://api.coingecko.com/api/v3/simple/price?ids=ethereum&vs_currencies=usd";
    string internal constant JQ_ETH_USD_QUERY = ".ethereum.usd | tostring";
}