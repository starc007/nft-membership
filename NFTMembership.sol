// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMembership is ERC721URIStorage {
    uint256 public tokenIds;
    address payable public owner;


    struct ListItem {
        uint256 tokenId;
        string tokenURI;
        uint256 price;
        address payable owner;
        address payable buyer;
        bool sold;
    }

    ListItem[] public listings;

    event ListingCreated(
        uint256 indexed tokenId,
        string tokenURI,
        uint256 price,
        address payable owner
        address payable buyer
        bool sold
    );

    constructor() ERC721("NFT Membership", "NFTM") {
        owner = msg.sender;
    }

    function createCollectible(
        string memory tokenURI,
        uint256 price,
    ) public returns (uint256) {
        uint256 newItemId = tokenIds++;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        createListing(newItemId, price, tokenURI);
        return newItemId;
    }

    function createListing (
        uint256 tokenId,
        uint256 price,
        string memory tokenURI,
    ) public returns (uint256) {
        require(price > 0, "Price must be at least 1 wei");
        
        ListItem memory listing = ListItem({
            tokenId: tokenId,
            tokenURI: tokenURI,
            price: price,
            owner: payable(msg.sender),
            buyer: payable(address(0)),
            sold: false
        });

        listings.push(listing);

        _transfer(msg.sender, address(this), tokenId);
        emit ListingCreated(tokenId,tokenURI, price, payable(msg.sender), payable(address(0)), false);
    }

    function buyCollectible(uint256 tokenId) public payable {
        ListItem storage listing = listings[tokenId];
        require(listing.price > 0, "Collectible not for sale");
        require(msg.value >= listing.price, "Insufficient funds sent");
        require(listing.sold == false, "Collectible already sold");

        listing.sold = true;
        listing.buyer = payable(msg.sender);
        listing.owner.transfer(msg.value);
        _transfer(address(this), msg.sender, tokenId);
    }

    function getAllListings() public view returns (ListItem[] memory) {
        ListItem[] memory _listings = new ListItem[](listings.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].sold == false) {
                _listings[counter] = listings[i];
                counter++;
            }
        }
        return _listings;
    }

    function myListing() public view returns (ListItem[] memory) {
        ListItem[] memory _listings = new ListItem[](listings.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].owner == msg.sender) {
                _listings[counter] = listings[i];
                counter++;
            }
        }
        return _listings;
    }

}
