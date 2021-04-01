// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.7.0;
// pragma experimental ABIEncoderV2;
import "./ERC721Contract.sol";


contract Hockey is ERC721Contract {
    address admin;
    uint256 playerId;

    struct HockeyCard {
        uint256 id;
        string name;
        uint256 rating;
        uint256 number;
    }
    uint256[] Id;
    mapping(uint256 => HockeyCard) public hockey;
    mapping(uint256 => address) public idToOwner;

    constructor() public {
        admin = msg.sender;

        HockeyCard memory poke = HockeyCard(playerId, "Auston Matthews", 100, 100);
        hockey[playerId] = poke;
        Id.push(playerId);
        mint(admin, playerId);
        idToOwner[playerId] = admin;
        playerId++;
    }

    function createPlayer(
        string calldata _name,
        uint256 _rating,
        uint256 _number
    ) external {
        require(_rating  < 100, "The attack power should be <100.");
        hockey[playerId] = HockeyCard(playerId, _name, _rating, _number);
        Id.push(playerId);
        mint(msg.sender, playerId);
        idToOwner[playerId] = msg.sender;
        playerId++;
    }

    function tradePlayer(uint256 _tokenId, address _to) external {

        address oldOwner = idToOwner[_tokenId];
        require(msg.sender == oldOwner, "Not authorized to tade");
        _safeTransfer(oldOwner, _to, _tokenId, "");
        idToOwner[_tokenId] = _to;
    }

    function getCardsId() public view returns (uint256[] memory) {
        return Id;
    }



}