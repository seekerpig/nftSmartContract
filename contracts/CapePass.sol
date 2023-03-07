pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT
//.........................................................................................................
//....CCCCCCC.......AAAAA.....PPPPPPPPP...EEEEEEEEEEE......PPPPPPPPP.....AAAA.......SSSSSSS.....SSSSSSS....
//...CCCCCCCCC......AAAAA.....PPPPPPPPPP..EEEEEEEEEEE......PPPPPPPPPP...AAAAAA.....ASSSSSSSS...SSSSSSSSS...
//..CCCCCCCCCCC....AAAAAA.....PPPPPPPPPPP.EEEEEEEEEEE......PPPPPPPPPPP..AAAAAA....AASSSSSSSSS.SSSSSSSSSSS..
//..CCCC...CCCCC...AAAAAAA....PPPP...PPPP.EEEE.............PPPP...PPPP..AAAAAAA...AASS...SSSS.SSSS...SSSS..
//.CCCC.....CCC...AAAAAAAA....PPPP...PPPP.EEEE.............PPPP...PPPP.AAAAAAAA...AASSS.......SSSSS........
//.CCCC...........AAAAAAAA....PPPPPPPPPPP.EEEEEEEEEE.......PPPPPPPPPPP.AAAAAAAA....ASSSSSS.....SSSSSSS.....
//.CCCC...........AAAA.AAAA...PPPPPPPPPP..EEEEEEEEEE.......PPPPPPPPPP..AAAA.AAAA....SSSSSSSS....SSSSSSSS...
//.CCCC..........AAAAAAAAAA...PPPPPPPPP...EEEEEEEEEE.......PPPPPPPPP..PAAAAAAAAA......SSSSSSS.....SSSSSSS..
//.CCCC.....CCC..AAAAAAAAAAA..PPPP........EEEE.............PPPP.......PAAAAAAAAAA........SSSSS.......SSSS..
//..CCCC...CCCCC.AAAAAAAAAAA..PPPP........EEEE.............PPPP......PPAAAAAAAAAA.AASS...SSSSSSSSS...SSSS..
//..CCCCCCCCCCC.AAAA....AAAA..PPPP........EEEEEEEEEEE......PPPP......PPAA....AAAA.AASSSSSSSSS.SSSSSSSSSSS..
//...CCCCCCCCCC.AAAA.....AAAA.PPPP........EEEEEEEEEEE......PPPP......PPAA....AAAAA.ASSSSSSSSS..SSSSSSSSSS..
//....CCCCCCC..CAAAA.....AAAA.PPPP........EEEEEEEEEEE......PPPP.....PPPAA.....AAAA..SSSSSSS.....SSSSSSS....
//.........................................................................................................


import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CapePass is ERC1155Supply, Ownable{
    bool public publicsaleIsActive = false;
    bool public privatesaleIsActive = false;
    uint public activeBadgeId = 1;
    uint public maxPerTransaction = 1;
    uint public maxPerWallet = 1;
    uint public maxSupply = 120;
    uint public constant NUMBER_RESERVED_TOKENS = 20;
    uint256 public constant PRICE = 10000000000000000; //0.01 ETH
    string public name = "Cape Pass";

    uint public reservedTokensMinted = 0;

    mapping(address => uint256) public WhiteListTokens;

    string public contractURIstr = "";

    constructor() ERC1155("https://ipfs.io/ipfs/QmZ5im37Mkz8k1F6ayM3WN25rcReCakXn8Wwur15rnTeN9/{id}.json") {}

    address payable private recipient1 = payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2); //partners payout address


    function contractURI() public view returns (string memory)
    {
       return contractURIstr;
    }

    function setContractURI(string memory newuri) external onlyOwner
    {
       contractURIstr = newuri;
    }

    function setURI(string memory newuri) external onlyOwner
    {
        _setURI(newuri);
    }

    function setName(string memory _name) public onlyOwner 
    {
        name = _name;
    }

    function getName() public view returns (string memory) 
    {
       return name;
    }

    function mintTokenPublic(uint256 amount) external payable
    {
        require(msg.sender == tx.origin, "No transaction from smart contracts!");
        require(publicsaleIsActive, "Public Sale must be active to mint");
        require(amount > 0 && amount <= maxPerTransaction, "Max per transaction reached, sale not allowed");
        require(balanceOf(msg.sender, activeBadgeId) + amount <= maxPerWallet, "Limit per wallet reached with this amount, sale not allowed");
        require(totalSupply(activeBadgeId) + amount <= maxSupply - (NUMBER_RESERVED_TOKENS - reservedTokensMinted), "Purchase would exceed max supply");
        require(msg.value >= PRICE * amount, "Not enough ETH for transaction");

        _mint(msg.sender, activeBadgeId, amount, "");
    }

    function mintTokenWhiteList(uint256 amount) external payable
    {
        require(msg.sender == tx.origin, "No transaction from smart contracts!");
        require(privatesaleIsActive, "Private Sale must be active to mint");
        require(amount <= WhiteListTokens[msg.sender], "The amount of tokens to mint exceeds your whitelisted token allowed");
        require(amount > 0 && amount <= maxPerTransaction, "Max per transaction reached, sale not allowed");
        require(balanceOf(msg.sender, activeBadgeId) + amount <= maxPerWallet, "Limit per wallet reached with this amount, sale not allowed");
        require(totalSupply(activeBadgeId) + amount <= maxSupply - (NUMBER_RESERVED_TOKENS - reservedTokensMinted), "Purchase would exceed max supply");
        require(msg.value >= PRICE * amount, "Not enough ETH for transaction");
        WhiteListTokens[msg.sender] -= amount;
        _mint(msg.sender, activeBadgeId, amount, "");
    }

    function setAllowList(address[] calldata addresses, uint256 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            WhiteListTokens[addresses[i]] = numAllowedToMint;
        }
    }

    function mintReservedTokens(address to, uint256 amount) external onlyOwner
    {
        require(reservedTokensMinted + amount <= NUMBER_RESERVED_TOKENS, "This amount is more than max allowed");

        _mint(to, activeBadgeId, amount, "");
        reservedTokensMinted = reservedTokensMinted + amount;
    }

    function withdraw() external
    {
        require(msg.sender == recipient1 || msg.sender == owner(), "Invalid sender");

        uint part = address(this).balance / 100 * 30;
        recipient1.transfer(part);
        payable(owner()).transfer(address(this).balance);
    }

    function flipPublicSaleState() external onlyOwner
    {
        publicsaleIsActive = !publicsaleIsActive;
    }
    function flipPrivateSaleState() external onlyOwner
    {
        privatesaleIsActive = !privatesaleIsActive;
    }

    function changeSaleDetails(uint _activeBadgeId, uint _maxPerTransaction, uint _maxPerWallet, uint _maxSupply) external onlyOwner
    {
        activeBadgeId = _activeBadgeId;
        maxPerTransaction = _maxPerTransaction;
        maxPerWallet = _maxPerWallet;
        maxSupply = _maxSupply;
    }
}
