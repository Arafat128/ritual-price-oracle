// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITEEServiceRegistry {
    function pickServiceByCapability(
        uint8 capability,
        bool checkValidity,
        uint256 seed,
        uint256 maxProbes
    ) external view returns (address teeAddress, bool found);

    function getIndexedServiceCountByCapability(uint8 capability) external view returns (uint256 count);

    function getIndexedServiceByCapabilityAt(uint8 capability, uint256 index) external view returns (address teeAddress);
}