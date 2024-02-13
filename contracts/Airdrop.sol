// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Airdrop is Ownable {
    IERC20 public airdropToken;
    uint256 internal airdropsCount = 1;

    struct AirdropInfos {
        bytes32 merkleRoot;
        uint256 numberOfUsers;
        uint256 startedAt;
        uint256 amount;
    }

    mapping(uint256 airdropID => AirdropInfos) airDrops;
    mapping(uint256 airdropID => mapping(address user => bool isClaimed)) claimStatus;

    event AirdropClaim(uint256 indexed airdropID, uint256 amount, address indexed claimer);

    constructor(address _airdropToken) Ownable(msg.sender) {
        airdropToken = IERC20(_airdropToken);
    }

    function initAirdrop(bytes32 _merkleRoot, uint256 _numberOfUsers, uint256 _amount)
        external
        onlyOwner
        returns (uint256 airdropID)
    {
        require(_merkleRoot != bytes32(0), "Airdrop: Merkle Root should not zero bytes");
        require(_numberOfUsers > 0, "Airdrop: number of users should not zero");
        airDrops[airdropsCount] =
            AirdropInfos({merkleRoot: _merkleRoot, numberOfUsers: _numberOfUsers, amount: _amount, startedAt: 0});
        airdropID = airdropsCount;
    }

    function reviseAirdropToken(address _airdropToken) external onlyOwner {
        require(_airdropToken != address(0), "Airdrop: Token should not zero address");
        airdropToken = IERC20(_airdropToken);
    }

    function checkTokenAvailability(uint256 airdropID) internal view returns (bool isAvailable) {
        AirdropInfos memory airdropInExecution = airDrops[airdropID];
        uint256 expectedBalanceToAirdrop = airdropInExecution.amount * airdropInExecution.numberOfUsers;
        isAvailable = airdropToken.balanceOf(address(this)) >= expectedBalanceToAirdrop ? true : false;
    }

    function claimTokens(bytes32[] memory _proof, uint256 airdropID) external {
        address claimer = msg.sender;
        AirdropInfos storage airdropInExecution = airDrops[airdropID];
        require(!claimStatus[airdropID][claimer], "Airdrop: User already claimed");
        require(checkTokenAvailability(airdropID), "Airdrop: token balance low to initiate airdrop claim");
        require(
            verify(_proof, claimer, airdropInExecution.amount, airdropID),
            "Airdrop: Invalid prrof submitted while claiming airdrop"
        );
        claimStatus[airdropID][claimer] = true;
        airdropInExecution.startedAt = block.timestamp;
        bool success = airdropToken.transfer(claimer, airdropInExecution.amount);
        require(success, "Airdrop: Token transfer failed");
        emit AirdropClaim(airdropID, airdropInExecution.amount, claimer);
    }

    function verify(bytes32[] memory merkleProof, address account, uint256 amount, uint256 airdropId)
        internal
        view
        returns (bool _isVerified)
    {
        require(merkleProof.length != 0, "Airdrop: Merkle Proof should not be zero length");
        require(account != address(0) && amount > 0, "Airdrop: Zero address & amount is not allowed");
        AirdropInfos memory airdropInExecution = airDrops[airdropId];
        bytes32 leafNode = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        _isVerified = MerkleProof.verify(merkleProof, airdropInExecution.merkleRoot, leafNode);
    }
}
