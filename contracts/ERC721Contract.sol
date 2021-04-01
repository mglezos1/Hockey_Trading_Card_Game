  
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.7.0;


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }
}

interface IERC721TokenReceiver {

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ERC721 {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;

    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);
}


contract ERC721Contract is ERC721 {
    using Address for address;

    mapping(address => uint256) private ownerTokenBalance;

    mapping(uint256 => address) private ownerOfToken;

    mapping(uint256 => address) private approvingIdOfToken;

    mapping(address => mapping(address => bool)) private operators;

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    uint256 private nextTokenId;

    address admin;

    constructor() public {
        admin = msg.sender;
    }

    function mint(address _owner, uint256 _tokenId) public {
        ownerTokenBalance[_owner]++;
        ownerOfToken[_tokenId] = _owner;
        emit Transfer(address(0), _owner, _tokenId);
        nextTokenId++;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return ownerTokenBalance[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return ownerOfToken[_tokenId];
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return approvingIdOfToken[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return operators[_owner][_operator];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata data
    ) external payable {
        _safeTransfer(_from, _to, _tokenId, data);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _safeTransfer(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {

        address owner = ownerOfToken[_tokenId];
        require(
            msg.sender == owner,
            "ERC721Contract: This is not Authorized Address."
        );
        approvingIdOfToken[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {

        operators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal allowTransfer(_tokenId) {
        ownerTokenBalance[_from] -= 1;
        ownerTokenBalance[_to] += 1;

        ownerOfToken[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        _transfer(_from, _to, _tokenId);
        if (_to.isContract()) {
            bytes4 retval = IERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _to,
                _tokenId,
                data
            );
            require(
                retval == MAGIC_ON_ERC721_RECEIVED,
                "recipient SC cannot handle ERC721 tokens"
            );
        }
    }

    modifier allowTransfer(uint256 _tokenId) {

        address owner = ownerOfToken[_tokenId];

        require(
            owner == msg.sender ||
                approvingIdOfToken[_tokenId] == msg.sender ||
                operators[owner][msg.sender] == true,
            "ERC721Contract: This is not Authorized Address."
        );
        _;
    }
}