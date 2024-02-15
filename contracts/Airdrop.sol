// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract Airdrop is Ownable2Step {
    using SafeERC20 for IERC20;

    IERC20 public airdropToken;
    uint256 internal airdropsCount = 1;
    uint256 thresholdBalance;
    uint256 constant CLAIM_START_DURATION = 5 days; // claim start after 5 days of init airdrop

    struct AirdropInfos {
        bytes32 merkleRoot;
        uint256 numberOfUsers;
        uint256 startedAt;
    }

    mapping(uint256 airdropID => AirdropInfos) airDrops;
    mapping(uint256 airdropID => mapping(address user => bool isClaimed)) claimStatus;

    event AirdropClaim(uint256 indexed airdropID, address indexed claimer, uint256 amount);
    event AirdropInit(uint256 indexed airdropID, uint256 indexed initAt, uint256 amount);
    event AirdropTokenRevised(address indexed oldToken, address indexed newToken);
    event ThresholdUpdated(uint256 indexed oldThreshold, uint256 indexed newThreshold);
    event ThresholdReached(uint256 indexed balance, uint256 threshold, string info);

    constructor(IERC20 _airdropToken, address _owner, uint256 _thresholdTokenAmount) Ownable(_owner) {
        airdropToken = _airdropToken;
        thresholdBalance = _thresholdTokenAmount;
    }

    function init(bytes32 _merkleRoot, uint256 _numberOfUsers, uint256 _amount)
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
        emit AirdropInit(airdropID, block.timestamp, _amount);
    }

    function revise(IERC20 _airdropToken) external onlyOwner {
        address newToken = address(_airdropToken);
        require(newToken != address(0), "Airdrop: Token should not zero address");
        address oldToken = address(airdropToken);
        airdropToken = _airdropToken;
        emit AirdropTokenRevised(oldToken, newToken);
    }

    function updateThresholdAmount(uint256 _threshold) external onlyOwner {
        uint256 oldThreshold = thresholdBalance;
        thresholdBalance = _threshold;
        emit ThresholdUpdated(oldThreshold, _threshold);
    }

    function withdrawTokens(uint256 _amount, address _receiver) external onlyOwner {
        require(_amount > 0 && airdropToken.balanceOf(address(this)) >= _amount, "Invalid balance of token to withdraw");
        bool success = airdropToken.transfer(_receiver, _amount);
        require(success, "Airdrop: token transfer failed while withdrawal");
    }

    function getAirdropInfo(uint256 _airdropID) public view returns (AirdropInfos memory info) {
        require(_airdropID > 0 && _airdropID <= airdropsCount, "Airdrop: invalid airdrop ID");
        info = airDrops[_airdropID];
    }

    function isThresholdReached(uint256 _amount) public returns (bool _isReached) {
        uint256 balance = airdropToken.balanceOf(address(this));
        if (balance <= thresholdBalance) {
            uint256 diff = balance - _amount;
            _isReached = (diff <= 5); // atleast hold 5 airdrop tokens.
            emit ThresholdReached(balance, thresholdBalance, "Top-up the airdrop token");
        }
    }

    // NOTE: user needs to put full claimable amount in _amount, since they have only one chance to claim the amount
    function claim(bytes32[] memory _proof, uint256 airdropID, uint256 _amount) external {
        address claimer = msg.sender;
        AirdropInfos memory airdropInExecution = airDrops[airdropID];
        require(
            block.timestamp > airdropInExecution.startedAt + CLAIM_START_DURATION,
            string(
                abi.encodePacked(
                    "Airdrop: Not yet started to claim. Wait for ",
                    (CLAIM_START_DURATION + airdropInExecution.startedAt) - block.timestamp,
                    " seconds"
                )
            )
        );
        require(!claimStatus[airdropID][claimer], "Airdrop: User already claimed");
        require(!isThresholdReached(_amount), "Airdrop: Threshold reached");
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
