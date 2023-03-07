pragma solidity ^0.8.0;

//SPDX-License-Identifier: MIT

import "./EventTrigger.sol";

contract Item{

    uint priceInWei;
    uint pricePaid;
    uint identifier;

    uint index;

    ItemManager parentContract;

    constructor(uint _priceInWei, uint _index, ItemManager _parentContract)
    {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    receive () external payable {
        require(pricePaid == 0, "item is already paid");
        require(priceInWei == msg.value, "payment is not equal to price of item");
        pricePaid += msg.value;
        parentContract.triggerPayment{value:msg.value}(index);
    
    }


}

