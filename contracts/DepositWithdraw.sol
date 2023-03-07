pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

contract DepositWithdraw{

    mapping (address => uint) public depositAmount;

    function deposit() payable public{
        depositAmount[msg.sender] += msg.value;
    }

    function withdrawMoney(uint _amount) public{
        require(depositAmount[msg.sender] >= _amount);

        payable(msg.sender).call{value:_amount}("");

        depositAmount[msg.sender] = 0;
        

    }

    function getBalance() public view returns (uint){
        return address(this).balance;
    }
}