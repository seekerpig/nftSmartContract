pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//SPDX-License-Identifier: MIT

import "./Item.sol";


contract ItemManager is Ownable{

    enum SupplyChainSteps{Created, Paid, Delivered}

    struct S_Item{
        Item item;
        ItemManager.SupplyChainSteps _step;
        string identifier;
        uint priceInWei;
    }

    mapping (uint => S_Item) public items;
    uint index;

    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);

    function createItem(string memory _identifier, uint _priceInWei) public onlyOwner{
        Item newItem = new Item(_priceInWei, index, this);
        items[index].item = newItem;
        items[index].identifier= _identifier;
        items[index].priceInWei = _priceInWei;
        items[index]._step = SupplyChainSteps.Created;
        emit SupplyChainStep(index, 0, address(newItem));
        index++;
    }

    function triggerPayment(uint _itemIndex) public payable {
        require(msg.value >= items[_itemIndex].priceInWei, "You do not have enough ether");
        require(items[_itemIndex]._step == SupplyChainSteps.Created, "Item is already paid");
        items[_itemIndex]._step = SupplyChainSteps.Paid;
        emit SupplyChainStep(_itemIndex, 1,address(items[_itemIndex].item));
    }

    function triggerDelivery(uint _itemIndex) public onlyOwner {
        require(items[_itemIndex]._step == SupplyChainSteps.Paid, "Item not paid yet");
        items[_itemIndex]._step = SupplyChainSteps.Delivered;
        emit SupplyChainStep(index, 2, address(items[_itemIndex].item));

    }



}