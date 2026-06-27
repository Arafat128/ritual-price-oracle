// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAsyncJobTracker {
    function hasPendingJobForSender(address sender) external view returns (bool);
}