//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IContractManager {
    function setAddress(string calldata _name, address _address) external;

    function getAddress(string calldata _name) external view returns (address);

    function deleteAddress(string calldata _name) external;
}