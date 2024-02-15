// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Airdrop is Ownable2Step {
    using SafeERC20 for IERC20;

    struct AirdropInfos {
        bytes32 merkleRoot;
        uint256 numberOfUsers;
        uint256 startedAt;
    }

    uint256 public constant CLAIM_START_DURATION = 5 days; // claim start after 5 days of init airdrop
    uint256 internal airdropsCount = 1;
    uint256 internal thresholdBalance;
    IERC20 public airdropToken;

    mapping(uint256 airdropID => mapping(address user => bool isClaimed)) internal claimStatus;
    mapping(uint256 airdropID => AirdropInfos) public airDrops;

    event AirdropClaim(uint256 indexed airdropID, address claimer, uint256 amount);
    event AirdropInit(uint256 indexed airdropID, uint256 initAt, uint256 claimStartAt);
    event AirdropTokenRevised(address newToken);
    event ThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event ThresholdReached(uint256 balance, uint256 threshold);

    constructor(IERC20 _airdropToken, address _owner, uint256 _thresholdTokenAmount) Ownable(_owner) {
        airdropToken = _airdropToken;
        thresholdBalance = _thresholdTokenAmount;
    }

    function init(bytes32 _merkleRoot, uint256 _numberOfUsers)
        external
        onlyOwner
        returns (uint256 airdropID)
    {
        require(_merkleRoot != bytes32(0), "Airdrop: Merkle Root should not zero bytes");
        require(_numberOfUsers > 0, "Airdrop: number of users should not zero");
        airDrops[airdropsCount] =
            AirdropInfos({merkleRoot: _merkleRoot, numberOfUsers: _numberOfUsers, startedAt: block.timestamp});
        airdropID = airdropsCount;
        airdropsCount++;
        emit AirdropInit(airdropID, block.timestamp, block.timestamp + CLAIM_START_DURATION);
    }

    function revise(IERC20 _airdropToken) external onlyOwner {
        require(address(_airdropToken) != address(0), "Airdrop: Token should not zero address");
        airdropToken = _airdropToken;
        emit AirdropTokenRevised(address(_airdropToken));
    }

    function updateThresholdAmount(uint256 _threshold) external onlyOwner {
        uint256 oldThreshold = thresholdBalance;
        thresholdBalance = _threshold;
        emit ThresholdUpdated(oldThreshold, _threshold);
    }

    function withdrawTokens(uint256 _amount, address _receiver) external onlyOwner {
        require(_amount > 0 && airdropToken.balanceOf(address(this)) >= _amount, "Invalid balance of token to withdraw");
        airdropToken.safeTransfer(_receiver, _amount);
    }

    // NOTE: user needs to put full claimable amount in _amount, since they have only one chance to claim the amount
    function claim(bytes32[] memory _proof, uint256 airdropID, uint256 _amount) external {
        address claimer = msg.sender;
        AirdropInfos memory airdropInExecution = airDrops[airdropID];
        require(block.timestamp > airdropInExecution.startedAt + CLAIM_START_DURATION, "Airdrop: Claim not started");

        require(!claimStatus[airdropID][claimer], "Airdrop: User already claimed");
        uint256 balance = airdropToken.balanceOf(address(this));
        if (balance <= thresholdBalance) {
            emit ThresholdReached(balance, thresholdBalance);
            revert("Token balance low to transfer");
        }
        require(
            verify(_proof, airdropInExecution.merkleRoot, claimer, _amount),
            "Airdrop: Invalid prrof submitted while claiming airdrop"
        );
        claimStatus[airdropID][claimer] = true;
        airdropToken.safeTransfer(claimer, _amount);
        emit AirdropClaim(airdropID, claimer, _amount);
    }

    function verify(bytes32[] memory merkleProof, bytes32 merkleRoot, address account, uint256 amount)
        internal
        pure
        returns (bool _isVerified)
    {
        require(merkleProof.length != 0, "Airdrop: Merkle Proof should not be zero length");
        require(account != address(0) && amount > 0, "Airdrop: Zero address & amount is not allowed");
        bytes32 leafNode = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        _isVerified = MerkleProof.verify(merkleProof, merkleRoot, leafNode);
    }
}
