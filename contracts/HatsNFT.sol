// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./openzeppelin-contracts-master/contracts/token/ERC721/IERC721.sol";
import "./openzeppelin-contracts-master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "./openzeppelin-contracts-master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./openzeppelin-contracts-master/contracts/token/ERC721/ERC721.sol";

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
    mapping(uint256 => address) public hatToPfpContract;
    mapping(uint256 => uint256) public hatToPfpContractId;
    
    constructor() ERC721("Hats NFT", "HAT") {}
    
    
    function mintHat(address to,string memory name, string memory design, string memory color, uint256 rarity) public returns (uint256) {
        uint256 hatId = nextHatId++;
        Hat memory newHat = Hat(hatId, name, design, color, rarity);
        hats[hatId] = newHat;
        hatOwners[hatId] = to;
        emit HatMinted(hatId, msg.sender, name, design, color, rarity);
        return hatId;
    }
    
    function attachHat(uint256 hatId, uint256 pfpId, address pfpContract) public {
        require(msg.sender == hatOwners[hatId], "You do not own this hat");
        require(msg.sender == ERC721(pfpContract).ownerOf(pfpId), "You do not own this PFP");
        hatToPfpContract[hatId] = pfpContract;
        hatToPfpContractId[hatId] = pfpId;

        emit HatAttached(hatId, pfpId, pfpContract);
    }

    function detachHat(uint256 pfpId) public {
        require(msg.sender == ERC721(hatToPfpContract[pfpId]).ownerOf(pfpId), "You do not own this PFP");
        uint256 hatId = hatToPfpContractId[pfpId];
        hatToPfpContract[hatId] = address(0);
        hatToPfpContractId[hatId] = 0;
        emit HatDetached(hatId);
    }
        
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // require(_exists(tokenId), "Token ID does not exist");
        address pfpContract = hatToPfpContract[tokenId];
        uint256 pfpId = hatToPfpContractId[tokenId];
        if (pfpContract == address(0)) {
            return generateHatMetadata(tokenId);
        } else {
            string memory pfpTokenURI = IERC721Metadata(pfpContract).tokenURI(pfpId);
            string memory json = string(abi.encodePacked(
                '{',
                    '"name":"', hats[tokenId].name, '",',
                    '"description":"', hats[tokenId].design, '",',
                    '"attributes":[{"trait_type":"color","value":"', hats[tokenId].color, '"},{"trait_type":"rarity","value":', uintToString(hats[tokenId].rarity), '}],',
                    '"image":"example.com/', uintToString(tokenId), '.png",',
                    '"pfp":', pfpTokenURI,
                '}'
            ));
            return json;
        }
    }

    function generateHatMetadata(uint256 hatId) private view returns (string memory) {
        Hat memory hat = hats[hatId];
        string memory json = string(abi.encodePacked(
            '{',
                '"name":"', hat.name, '",',
                '"description":"', hat.design, '",',
                '"attributes":[{"trait_type":"color","value":"', hat.color, '"},{"trait_type":"rarity","value":', uintToString(hat.rarity), '}],',
                '"image":"ipfs://', uintToString(hatId), '.png"',
            '}'
        ));
        return json;
    }

    function uintToString(uint256 v) private pure returns (string memory) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        if (v == 0) {
            reversed[i++] = bytes1(uint8(48));
        }
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
    event HatDetached(uint256 hatId);
    event HatTransfer(address from, address to, uint256 tokenId, uint256 hatId);
}