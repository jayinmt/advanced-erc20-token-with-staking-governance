# Advanced ERC20 Token with Staking and Governance

This project implements an advanced ERC20 token contract that incorporates staking and governance functionality. The token contract is written in Solidity and utilizes the OpenZeppelin library for standard ERC20 functionality, access control, and upgradability.

## Features

- Standard ERC20 functionality (transfer, approve, transferFrom, balanceOf, etc.)
- Staking mechanism: Users can stake their tokens to earn rewards based on the staking duration and a configurable reward rate.
- Governance: Token holders can propose and vote on governance proposals. The voting power is proportional to the number of tokens staked by each user.
- Timelock: A timelock feature is introduced for executing approved governance proposals, providing a delay between the proposal's approval and its execution.
- Upgradability: The contract utilizes a proxy pattern (UUPS) to enable future enhancements and bug fixes without requiring a full contract migration.
- Access control: Role-based access control is implemented using OpenZeppelin's AccessControl library to restrict certain functions to specific roles (e.g., admin, minter).
- Events: The contract emits events for important actions such as staking, unstaking, proposal creation, voting, and proposal execution.

## Prerequisites

- Solidity ^0.8.0
- OpenZeppelin Contracts library v4.x

## Installation

1. Clone the repository:

```bash
git clone https://github.com/jayinmt/advanced-erc20-token-with-staking-governance.git
```

2. Install the required dependencies:

```bash
npm install
```

## Usage

1. Deploy the contract:

```bash
truffle migrate
```

2. Interact with the contract using a web3 interface or a script:

```javascript
const AdvancedToken = artifacts.require("AdvancedToken");

module.exports = async function(callback) {
  try {
    const token = await AdvancedToken.deployed();
    
    // Mint tokens
    await token.mint(accounts[1], web3.utils.toWei("1000"));
    
    // Stake tokens
    await token.stake(web3.utils.toWei("500"), { from: accounts[1] });
    
    // Create a proposal
    await token.createProposal("Proposal description", { from: accounts[0] });
    
    // Vote on a proposal
    await token.vote(0, true, { from: accounts[1] });
    
    // Execute a proposal
    await token.executeProposal(0, { from: accounts[0] });
    
    callback();
  } catch (error) {
    callback(error);
  }
};
```

## Contract Functions

- `stake(uint256 amount)`: Stake tokens and start earning rewards.
- `unstake(uint256 amount)`: Unstake tokens and claim earned rewards.
- `createProposal(string memory description)`: Create a new governance proposal.
- `vote(uint256 proposalId, bool vote)`: Vote on a governance proposal.
- `executeProposal(uint256 proposalId)`: Execute an approved governance proposal.
- `mint(address to, uint256 amount)`: Mint new tokens (restricted to the minter role).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Disclaimer

This contract is provided as-is and should be thoroughly tested and audited before deployment to a live network. The authors and contributors of this project are not responsible for any potential risks or damages arising from the use or misuse of this contract.
