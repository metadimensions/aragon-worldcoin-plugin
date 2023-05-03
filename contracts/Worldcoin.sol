// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Integrates Worldcoin with Aragon OSX - enabling users to join the DAO
// One user per One worldID

//Import Worldcoin contract and necessary libraries

import "@aragon/os/contracts/common/SafeMath.sol";
import "@aragon/os/contracts/token/ERC20/IERC20.sol";
import "@aragon/os/contracts/acl/IACLSyntaxInterpreter.sol";
import "./Worldcoin.sol";


contract WorldcoinDAOPlugin {
    
    using SafeMath for uint256;
    IERC20 public token;

    // Aragon specific
    IACLSyntaxInterpreter public aclSyntaxInterpreter;
    bytes32 public constant ARAGON_CREATE_PERMISSION = keccak256("CREATE_PERMISSIONS_ROLE");

    // DAO details
    address public daoAddress;
    bytes32 public tokenMintRole;
    mapping(address => bool) public members;
    uint256 public totalMembers;

    constructor(
        address _dao,
        address _worldcoinAddress, 
        bytes32 _tokenMintRole
    ) public {
        daoAddress = _dao;
        token = IERC20(_worldcoinAddress);
        aclSyntaxInterpreter = IACLSyntaxInterpreter(msg.sender);
        tokenMintRole = _tokenMintRole;
    }

    function joinDAO(string memory worldID) public {
        require(members[msg.sender] == false, "Already a member");
        require(Worldcoin(worldcoinAddress).verifyUser(worldID), "Invalid World ID");

        // Grant permission to mint tokens to this user
        aclSyntaxInterpreter.createPermission(msg.sender, address(token), tokenMintRole, msg.sender);

        // Mint token to user
        token.mint(msg.sender, 1);

        // Add user as member of DAO
        aclSyntaxInterpreter.createPermission(msg.sender, daoAddress, "", ARAGON_CREATE_PERMISSION);
        members[msg.sender] = true;
        totalMembers = totalMembers.add(1);
    }

    function createDAO(string memory worldID) public {
        require(members[msg.sender]==false, "Already a member");
    }
}
