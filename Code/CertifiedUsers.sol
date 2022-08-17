// SPDX-License-Identifier: DIKU
pragma solidity ^0.8.0;

contract CertifiedUsers {

    struct User {
        string companyName;
        address account;
    }

    User[] _certifiedUsers;
    address _owner;

    constructor(){
        _owner = msg.sender;
    }

    function checkCertified (address account) private view returns (bool){
        for (uint256 i=0; i< _certifiedUsers.length; i++){
            address current = _certifiedUsers[i].account;
            if (current == account){
                return true;
            }
        }
        return false;
    }

    modifier isCertified(address user){
        require(checkCertified(user), "User not certified trader");
        _;
    }

    modifier onlyOwner(){
        require (msg.sender == _owner, "Owner-only function");
        _;
    }

    // Adds a company and its account to be a certified user.
    function _certifyUser(string memory name, address account) internal onlyOwner() {
        _certifiedUsers.push(User(name, account));
    }

    // Removes the certified user at a given index.
    function remove(uint _index) private {
        for (uint i = _index; i < _certifiedUsers.length - 1; i++) {
            _certifiedUsers[i] = _certifiedUsers[i + 1];
        }
        _certifiedUsers.pop();
    }

    // Removes a company from the list of certified users.
    function _removeUser(string memory name) internal onlyOwner() {
        for (uint256 i=0; i< _certifiedUsers.length; i++){
            string memory current = _certifiedUsers[i].companyName;
            if (keccak256(bytes(current)) == keccak256(bytes(name))){
                remove(i);
            }
        }
    }

    // Returns the owner of an account.
    function accountOwner(address account) public view onlyOwner() isCertified(account) returns (string memory) {
        for (uint256 i=0; i< _certifiedUsers.length; i++){
            address current = _certifiedUsers[i].account;
            if (current == account){
                return _certifiedUsers[i].companyName;
            }
        }
        return ""; // Impossible to reach here, since we require the account to be certified to begin with.
    }

    // Returns address of a companies account. 0-address if unknown.
    function companyAccount(string memory company) public view onlyOwner() returns (address) {
        for (uint256 i=0; i< _certifiedUsers.length; i++){
            string memory current = _certifiedUsers[i].companyName;
            if (keccak256(bytes(current)) == keccak256(bytes(company))){
                return _certifiedUsers[i].account;
            }
        }
        return address(0);
    }
}