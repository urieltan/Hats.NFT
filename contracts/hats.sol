// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzeppelin-contracts-master/contracts/token/ERC721/IERC721.sol";
import "./openzeppelin-contracts-master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./openzeppelin-contracts-master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract HatsNFT is ERC721URIStorage {
    struct Hat {
        uint256 id;
        string name;
        string design;
        string color;
        uint256 rarity;
    }
    
    uint256 public nextHatId = 0;
    mapping(uint256 => Hat) public hats;
    mapping(uint256 => address) public hatOwners;
    mapping(uint256 => uint256) public pfpToHat;
    
    constructor() ERC721("Hats NFT", "HAT") {}
    
    
    function mintHat(string memory name, string memory design, string memory color, uint256 rarity) public returns (uint256) {
        uint256 hatId = nextHatId++;
        Hat memory newHat = Hat(hatId, name, design, color, rarity);
        hats[hatId] = newHat;
        hatOwners[hatId] = msg.sender;
        emit HatMinted(hatId, msg.sender, name, design, color, rarity);
        return hatId;
    }
    
    function transferToContract(address from, uint256 tokenId, uint256 hatId) public {
        IERC721 pfpContract = IERC721(msg.sender);
        require(pfpContract.ownerOf(tokenId) == from, "You must own the PFP NFT to attach a hat");
        require(pfpContract.getApproved(tokenId) == address(this), "You must approve HatsNFT as a spender");
        require(hatOwners[hatId] == address(this), "The hat must be owned by HatsNFT to attach it");
        
        bytes memory data = abi.encode(hatId);
        pfpContract.safeTransferFrom(from, address(this), tokenId, data);
        emit HatTransfer(from, address(this), tokenId, hatId);
    }
        
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        address pfpContract = ownerOf(tokenId);
        if (pfpToHat[tokenId] == 0) {
            string memory hatMetadata = generateHatMetadata(tokenId);
            string memory metadata = string(abi.encodePacked(hatMetadata));
            return metadata;
        } else {
            string memory pfpMetadata = IERC721Metadata(pfpContract).tokenURI(tokenId);
            string memory hatMetadata = generateHatMetadata(pfpToHat[tokenId]);
            string memory concatenatedMetadata = string(abi.encodePacked(pfpMetadata, hatMetadata));
            return concatenatedMetadata;
        }
    }

    function generateHatMetadata(uint256 hatId) private view returns (string memory) {
        Hat memory hat = hats[hatId];
        string memory json = string(abi.encodePacked(
            '{',
                '"name":"', hat.name, '",',
                '"description":"', hat.design, '",',
                '"attributes":[{"trait_type":"color","value":"', hat.color, '"},{"trait_type":"rarity","value":', uintToString(hat.rarity), '}],',
                '"image":"ipfs://', hatId, '.png"',
            '}'
        ));
        return json;
    }

    function uintToString(uint256 v) private pure returns (string memory) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i); // Set size
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // Populate from the end
        }
        string memory str = string(s); // Convert to string
        return str;
    }

    event HatMinted(uint256 hatId, address owner, string name, string design, string color, uint256 rarity);
    event HatAttached(uint256 hatId, uint256 tokenId, address owner);
    event HatTransfer(address from, address to, uint256 tokenId, uint256 hatId);



}