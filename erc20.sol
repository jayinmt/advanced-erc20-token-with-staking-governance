// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract AdvancedToken is ERC20, ERC20Burnable, AccessControl, Initializable, UUPSUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    uint256 public rewardRate;
    uint256 public proposalCounter;
    uint256 public proposalTimelock;
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
    }
    
    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public stakingTimestamps;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsPaid(address indexed user, uint256 amount);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, bool vote);
    event ProposalExecuted(uint256 indexed proposalId);
    
    function initialize(string memory name, string memory symbol, uint256 initialSupply, uint256 _rewardRate, uint256 _proposalTimelock) public initializer {
        __ERC20_init(name, symbol);
        __AccessControl_init();
        
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        
        rewardRate = _rewardRate;
        proposalTimelock = _proposalTimelock;
        
        _mint(msg.sender, initialSupply);
    }
    
    function stake(uint256 amount) public {
        require(amount > 0, "Cannot stake 0 tokens");
        _burn(msg.sender, amount);
        stakedBalances[msg.sender] += amount;
        stakingTimestamps[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }
    
    function unstake(uint256 amount) public {
        require(amount > 0, "Cannot unstake 0 tokens");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalances[msg.sender] -= amount;
        _mint(msg.sender, amount);
        
        uint256 reward = calculateReward(msg.sender);
        if (reward > 0) {
            _mint(msg.sender, reward);
            emit RewardsPaid(msg.sender, reward);
        }
        
        emit Unstaked(msg.sender, amount);
    }
    
    function calculateReward(address user) public view returns (uint256) {
        uint256 stakedDuration = block.timestamp - stakingTimestamps[user];
        return (stakedBalances[user] * rewardRate * stakedDuration) / (365 days);
    }
    
    function createProposal(string memory description) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can create proposals");
        uint256 proposalId = proposalCounter++;
        proposals[proposalId] = Proposal({
            id: proposalId,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            deadline: block.timestamp + proposalTimelock,
            executed: false
        });
        emit ProposalCreated(proposalId, description);
    }
    
    function vote(uint256 proposalId, bool vote) public {
        require(stakedBalances[msg.sender] > 0, "Must have staked tokens to vote");
        require(!hasVoted[proposalId][msg.sender], "Already voted on this proposal");
        require(block.timestamp < proposals[proposalId].deadline, "Voting period has ended");
        
        if (vote) {
            proposals[proposalId].votesFor += stakedBalances[msg.sender];
        } else {
            proposals[proposalId].votesAgainst += stakedBalances[msg.sender];
        }
        
        hasVoted[proposalId][msg.sender] = true;
        emit Voted(proposalId, msg.sender, vote);
    }
    
    function executeProposal(uint256 proposalId) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can execute proposals");
        require(block.timestamp >= proposals[proposalId].deadline, "Timelock period not yet passed");
        require(!proposals[proposalId].executed, "Proposal already executed");
        require(proposals[proposalId].votesFor > proposals[proposalId].votesAgainst, "Proposal did not pass");
        
        proposals[proposalId].executed = true;
        // Execute the proposal (add your logic here)
        
        emit ProposalExecuted(proposalId);
    }
    
    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Only minter can mint tokens");
        _mint(to, amount);
    }
    
    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) {}
}
