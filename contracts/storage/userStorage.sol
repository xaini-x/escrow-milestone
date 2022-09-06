// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../access/Ownable.sol";

contract UserRegister is Ownable {
     mapping(address => UserKyc) public user;
      struct UserKyc {
        address addrs;
        string uri;
        bool accepted;
    }
   
    struct UserProfession {
        address addrs;
        string Profession;
        string uri;
        bool accepted;
    }
    // mapping key to specific value;
    mapping(address => UserProfession) public _applied;
    //mapping for check if profession exist or not
    mapping(string => bool) public _profession;
    // user registered with profession
    mapping(address => string) private index;
    // store all profession type
    string[] public profession;


// register and wait for kyc 
function userKyc(address _user , string memory _uri ) public onlyOwner{
user[_user].accepted = true;
user[_user].uri = _uri;

}
    //profession are only created by only admin
    // give error if profession already existed
    function createProfession(string[] memory _professions) external onlyOwner {
        
        for (uint256 i = 0; i < _professions.length; i++) {
            require(
                _profession[_professions[i]] == false,
                "profession already existed"
            );
            _profession[_professions[i]] = true;
            profession.push(_professions[i]);
        }
    }

    // show all available profession that a user can apply
    function showProfession() external view returns (string[] memory) {
        return profession;
    }

    // user enter type and uri to apply for a profession
    function applyUser(string memory _professions, string memory uri)
        external
        virtual
    {
         require(
            user[msg.sender].accepted == true,
            " User not registered"
        );
        require(
            _applied[msg.sender].addrs != msg.sender,
            " Waiting for admin approval"
        );
        require(_profession[_professions] == true, "profession type not available");
        require(
            _applied[msg.sender].accepted == false,
            " User already assigned a profession"
        );
        _applied[msg.sender].Profession = _professions;
        _applied[msg.sender].addrs = msg.sender;
        _applied[msg.sender].uri = uri;
      
    }

    // admin check if user is elgible
    // only admin can assigned  profession to a user
    // if rejected user detail will delete
    function approveUser(address addr, bool approve) external onlyOwner {
        require(_applied[addr].addrs == addr, "User not found ");
        require(
            _applied[addr].accepted != true,
            " User already assigned a profession ."
        );
        if (approve == true) {
            //  approve address.
            _applied[addr].accepted = true;
            // using mapping to assigned address to the profession.
            index[addr] = _applied[addr].Profession;
       
        }

        //delete profile if not approved
        else {
            delete _applied[addr].Profession;
            delete _applied[addr].addrs;
            delete _applied[addr].uri;
        
        }
    }

    // checking the value bound with the address .
    function userType(address addr) external view returns ( string memory) {
        // return value from (users)array => (index)mapping => (addr) specific address -1{(array start from 0)}
        return  index[addr];
    }

    // delete existing user
    function deleteUser() external {
        require(_applied[msg.sender].accepted == true, "No user exist");
        delete index[msg.sender];
        delete _applied[msg.sender];
    }

function isRegistered(address _user) public view returns(bool status){
return user[_user].accepted ;
}}
// ["electrician","plumber","escrow Agent","inspector"]
