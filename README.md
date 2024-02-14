# :parachute: Airdrop Contract :parachute:
---

This Solidity smart contract implements an airdrop functionality for distributing tokens to multiple users based on a Merkle tree. Users can claim their portion of tokens by providing a valid Merkle proof.

## Features

- **Airdrop Initialization**: Owner can initialize a new airdrop by providing the Merkle root, number of users, and amount of tokens to be distributed.
- **Token Revision**: Owner can update the token contract address if needed.
- **Claim**: Users can claim their tokens by providing a valid Merkle proof.

## Getting Started :rocket:	

1. Deploy the contract to the Ethereum blockchain.
2. Initialize a new airdrop using the `init` function.
3. Distribute the tokens to the contract address.
4. Users can claim their tokens using the `claim` function.


## Usage

### `init(bytes32 _merkleRoot, uint256 _numberOfUsers, uint256 _amount)`

Initialize a new airdrop with the Merkle root, number of users, and amount of tokens to be distributed.

### `revise(IERC20 _airdropToken)`

Update the token contract address.

### `claim(bytes32[] memory _proof, uint256 airdropID)`

Claim tokens by providing a valid Merkle proof.

## Notes :brain:	

- Ensure that enough tokens are deposited to the contract address before users claim their tokens.
- Users cannot claim tokens multiple times in same airdrop.
- Ensure the validity of Merkle proofs before processing claims.

