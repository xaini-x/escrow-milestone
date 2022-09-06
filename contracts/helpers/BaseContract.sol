// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "../access/Ownable.sol";

contract BaseContract is Ownable {
    address internal managerAddress;

    function setManagerAddress(address _managerAddress) public onlyOwner {
        managerAddress = _managerAddress;
    }

    function getManagerAddress() public view returns(address){
        return managerAddress;
    }
}