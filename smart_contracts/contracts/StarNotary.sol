pragma solidity ^0.5.0;

import './ERC721Token.sol';

contract StarNotary is ERC721Token {

    struct Star{
        string name;
        string starStory;
        string dec;
        string mag;
        string cent;
    }
    
    mapping(bytes32 => bool) uniqueFactor;

    mapping(uint256 => Star) public tokenIdToStarInfo;

    mapping(uint256 => uint256) public starsForSale;

    

    function createStar(string memory _name,
    string memory _starStory, string memory _ra,
    string memory _dec, string memory _mag, uint256 _tokenId) public{
        bytes32 uq = sha256(abi.encodePacked(_ra, _dec, _mag));
        require(uniqueFactor(uq),"I'm Here");

        Star memory newStar = Star(_name,_starStory, _dec, _mag, _ra);
       
        uniqueFactor(uq) = true;

        tokenIdToStarInfo[_tokenId] = newStar;

        ERC721Token.mint(_tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(this.ownerOf(_tokenId) == msg.sender," You Don't own me");

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0," I'm not for sale or I don't exist yet");
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost,"You don't have enough Funds");
        

        clearPreviousStarState(_tokenId);

        transferFromHelper(starOwner, msg.sender, _tokenId);

        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }

        starOwner.transfer(starCost);
    }

    function clearPreviousStarState(uint256 _tokenId) private {
        //clear approvals
        tokenToApproved[_tokenId] = address(0);

        //clear being on sale
        starsForSale[_tokenId] = 0;
    }
}