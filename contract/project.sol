// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PensionFund {
    address public admin;

    struct Pensioner {
        string name;
        uint age;
        uint contribution;
        uint pensionBalance;
        bool isRegistered;
        bool isRetired;
    }

    mapping(address => Pensioner) public pensioners;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(pensioners[msg.sender].isRegistered, "Not a registered pensioner");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerPensioner(address _pensioner, string memory _name, uint _age) public onlyAdmin {
        require(!pensioners[_pensioner].isRegistered, "Pensioner already registered");
        pensioners[_pensioner] = Pensioner(_name, _age, 0, 0, true, false);
    }

    function contribute() public payable onlyRegistered {
        require(!pensioners[msg.sender].isRetired, "Retired pensioners can't contribute");
        pensioners[msg.sender].contribution += msg.value;
        pensioners[msg.sender].pensionBalance += msg.value;
    }

    function markAsRetired(address _pensioner) public onlyAdmin {
        require(pensioners[_pensioner].isRegistered, "Not registered");
        pensioners[_pensioner].isRetired = true;
    }

    function withdrawPension(uint _amount) public onlyRegistered {
        Pensioner storage p = pensioners[msg.sender];
        require(p.isRetired, "Only retired pensioners can withdraw pension");
        require(p.pensionBalance >= _amount, "Insufficient balance");

        p.pensionBalance -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function getPensionBalance() public view onlyRegistered returns (uint) {
        return pensioners[msg.sender].pensionBalance;
    }

    function getPensionerInfo(address _pensioner) public view returns (
        string memory name,
        uint age,
        uint contribution,
        uint pensionBalance,
        bool isRegistered,
        bool isRetired
    ) {
        Pensioner memory p = pensioners[_pensioner];
        return (p.name, p.age, p.contribution, p.pensionBalance, p.isRegistered, p.isRetired);
    }
}

