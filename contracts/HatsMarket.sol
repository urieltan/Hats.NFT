pragma solidity^0.8.0;

// Huang SiTing（A0254423L）
// Chua Yong Keng (A0254424J)
// Liu Yaqi (A0254426E)
// Tan Hong Jie Uriel (A0184411M)

import "./HatsNFT.sol";

contract HatsMarket {
    HatsNFT public hatsContract;
    mapping(uint256 => uint256) public listings;
    mapping(uint256 => address) public listingOwners;
    address public owner;

    constructor(HatsNFT _hatsContract) {
        hatsContract = _hatsContract;
    }
    
    function list(uint256 id, uint256 price) public {
        require(hatsContract.ownerOf(id) == msg.sender, "only owner can list");
        require(listings[id] == 0, "dice is already listed");
        hatsContract.transferFrom(msg.sender, address(this), id);
        listings[id] = price;
        listingOwners[id] = msg.sender;
    }

    function unlist(uint256 id) public {
        require(listings[id] > 0, "dice is not listed");
        require(listingOwners[id] == msg.sender, "only owner can unlist");
        hatsContract.transferFrom(address(this), msg.sender, id);
        listings[id] = 0;
        listingOwners[id] = address(0);
    }

    function checkPrice(uint256 id) public view returns(uint256) {
        return listings[id];
    }

    function buy(uint256 id) public payable {
        require(listings[id] > 0, "dice is not listed");
        require(msg.value >= listings[id], "not enough money");
        uint256 price = listings[id];
        address owner = listingOwners[id];
        hatsContract.transferFrom(address(this), msg.sender, id);
        listings[id] = 0;
        listingOwners[id] = address(0);
        payable(owner).transfer(price);
    }
}