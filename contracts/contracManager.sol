// SPDX-License-Identifier: MIT'
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ContractManager is Ownable {
    mapping(string => address) private addressOf;

    function setAddress(string memory _name, address _address)
        public
        onlyOwner
    {
        addressOf[_name] = _address;
    }

    function getAddress(string memory _name) public view returns (address) {
        return addressOf[_name];
    }

    function deleteAddress(string memory _name) public onlyOwner {
        addressOf[_name] = address(0);
    }
}