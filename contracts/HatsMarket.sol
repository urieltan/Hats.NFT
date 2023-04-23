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
        require(hatsContract.ownerOf(id) == address(this), "only owner can unlist");
        require(listings[id] > 0, "dice is not listed");
        hatsContract.transferFrom(address(this), msg.sender, id);
        listings[id] = 0;
    }

    function checkPrice(uint256 id) public view returns(uint256) {
        return listings[id];
    }

    function buy(uint256 id) public payable {
        uint256 price = listings[id];
        require(price > 0, "dice is not listed");
        require(msg.value >= price, "insufficient funds");

        uint256 receive_amount = price - commission;
        uint256 refund_amount = msg.value - price;

        payable(diceContract.getDicePrevOwner(id)).transfer(receive_amount);
        payable(owner).transfer(commission);
        if(refund_amount > 0){
            payable(msg.sender).transfer(refund_amount);
        }
        diceContract.transfer(id, msg.sender);
    }
}