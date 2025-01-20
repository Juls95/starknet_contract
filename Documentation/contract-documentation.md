# AI Decision Markets - Smart Contract Documentation

## Table of Contents
1. [Contract Overview](#contract-overview)
2. [Core Functionality](#core-functionality)
3. [Data Structures](#data-structures)
4. [Contract Functions](#contract-functions)
5. [Events](#events)
6. [Deployment Guide](#deployment-guide)

## Contract Overview

The AI Decision Markets smart contract enables users to create and participate in prediction markets where outcomes are determined by AI-driven decisions. The contract manages market creation, betting, and resolution processes while ensuring secure and transparent operations on the Starknet blockchain.

## Core Functionality

### Market Lifecycle
1. **Creation**: Markets are created with a description and end time
2. **Active Phase**: Users can place bets on expected outcomes
3. **Resolution**: Creator resolves market with AI-validated outcome
4. **Claiming**: Winners can claim their rewards

### Status Flow
```
OPEN (1) -> CLOSED (2) -> RESOLVED (3)
```

## Data Structures

### Market Structure
```cairo
struct Market {
    creator: ContractAddress,      // Address of market creator
    description: felt252,          // Market description
    end_time: u64,                // Unix timestamp for market end
    total_stakes: u256,           // Total amount staked
    outcome: u8,                  // Final outcome (0 if unresolved)
    status: u8,                   // Market status (1=open, 2=closed, 3=resolved)
}
```

### Bet Structure
```cairo
struct Bet {
    amount: u256,                 // Staked amount
    prediction: u8,               // Predicted outcome
    claimed: bool                 // Whether rewards were claimed
}
```

### Resolution Structure
```cairo
struct Resolution {
    resolved_outcome: u8,         // Final determined outcome
    resolution_time: u64,         // Time of resolution
    ai_validation_hash: felt252,  // Hash of AI validation data
    total_winning_stakes: u256    // Total stakes on winning outcome
}
```

## Contract Functions

### Market Management

#### create_market
```cairo
fn create_market(description: felt252, end_time: u64) -> u256
```
- Creates new prediction market
- Returns market ID
- Emits `MarketCreated` event

#### place_bet
```cairo
fn place_bet(market_id: u256, prediction: u8, amount: u256)
```
- Places bet on specific market
- Requires market to be open
- Emits `BetPlaced` event

#### resolve_market
```cairo
fn resolve_market(market_id: u256, outcome: u8, ai_validation_hash: felt252)
```
- Resolves market with final outcome
- Only creator can call
- Requires market end time passed
- Emits `MarketResolved` event

#### claim_reward
```cairo
fn claim_reward(market_id: u256)
```
- Claims rewards for winning bets
- Requires market resolved
- Emits `RewardClaimed` event

### View Functions

#### get_market_info
```cairo
fn get_market_info(market_id: u256) -> Market
```
- Returns market details

#### get_bet_info
```cairo
fn get_bet_info(market_id: u256, user: ContractAddress) -> Bet
```
- Returns bet details for user

#### get_resolution_info
```cairo
fn get_resolution_info(market_id: u256) -> Resolution
```
- Returns resolution details

## Events

### MarketCreated
```cairo
struct MarketCreated {
    market_id: u256,
    creator: ContractAddress,
    description: felt252,
    end_time: u64,
}
```

### BetPlaced
```cairo
struct BetPlaced {
    market_id: u256,
    user: ContractAddress,
    amount: u256,
    prediction: u8,
}
```

### MarketResolved
```cairo
struct MarketResolved {
    market_id: u256,
    outcome: u8,
    resolution_time: u64,
    ai_validation_hash: felt252,
}
```

### RewardClaimed
```cairo
struct RewardClaimed {
    market_id: u256,
    user: ContractAddress,
    amount: u256,
}
```

## Deployment Guide

### Prerequisites
1. Install Starkli:
```bash
curl https://get.starkli.sh | sh
```

2. Install Scarb:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

### Steps to Deploy

1. **Prepare Environment**
```bash
# Create a new keystore
starkli signer keystore new ~/.starkli-wallets/deployer

# Export account address
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/account.json

# Export private key
export STARKNET_PRIVATE_KEY=~/.starkli-wallets/deployer/privatekey.json
```

2. **Compile Contract**
```bash
scarb build
```

3. **Declare Contract**
```bash
starkli declare target/dev/ai_decision_market_DecisionMarket.contract_class.json
```

4. **Deploy Contract**
```bash
starkli deploy <CLASS_HASH>
```

5. **Verify Deployment**
- Save the contract address
- Check deployment on [Starkscan](https://testnet.starkscan.co)
- Test basic functions using Starkli CLI

### Important Notes
- Always deploy to testnet first (Goerli)
- Test all functions thoroughly before mainnet deployment
- Keep deployment addresses and transaction hashes for reference
- Monitor gas costs during testing
- Ensure proper error handling is in place

### After Deployment
1. Save the contract address for frontend integration
2. Generate contract ABI for frontend use
3. Test all functions through frontend integration
4. Monitor contract events and transaction success
5. Document any issues or unexpected behaviors

Remember to always test thoroughly on testnet before considering mainnet deployment. The contract handles financial transactions, so security and proper function verification are crucial.