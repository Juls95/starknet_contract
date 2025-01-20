# AI Decision Markets Smart Contract

A decentralized prediction market platform built on StarkNet where market outcomes are validated by AI. This smart contract enables users to create markets, place bets, and earn rewards based on correct predictions.

## Overview

The AI Decision Markets contract allows users to:
- Create prediction markets with specific end times
- Place bets on expected outcomes
- Resolve markets using AI-validated results
- Claim rewards for winning predictions

### Market Lifecycle

1. **Creation**: Any user can create a market by providing:
   - Description (what the market is about)
   - End time (when betting closes)

2. **Active Phase**: 
   - Users can place bets on their predicted outcomes
   - All bets must be placed before the market end time

3. **Resolution**: 
   - After end time, the market creator resolves the market
   - Resolution requires AI validation (through validation hash)

4. **Claiming**:
   - Winners can claim their rewards
   - Rewards are proportional to stake amount

## Contract Functions

### For Market Creators

```cairo
fn create_market(description: felt252, end_time: u64) -> u256
```
Creates a new market and returns the market ID.

```cairo
fn resolve_market(market_id: u256, outcome: u8, ai_validation_hash: felt252)
```
Resolves a market with the final outcome and AI validation.

### For Bettors

```cairo
fn place_bet(market_id: u256, prediction: u8, amount: u256)
```
Places a bet on a specific market outcome.

```cairo
fn claim_reward(market_id: u256)
```
Claims rewards for winning bets.

### View Functions

```cairo
fn get_market_info(market_id: u256) -> Market
```
Returns market details including creator, description, end time, and status.

```cairo
fn get_bet_info(market_id: u256, user: ContractAddress) -> Bet
```
Returns bet details for a specific user on a market.

```cairo
fn get_resolution_info(market_id: u256) -> Resolution
```
Returns resolution details including outcome and AI validation.

## Market States

Markets can be in one of three states:
- `OPEN (1)`: Accepting bets
- `CLOSED (2)`: Betting period ended
- `RESOLVED (3)`: Outcome determined

## Events

The contract emits the following events:

```cairo
MarketCreated { 
    market_id: u256,
    creator: ContractAddress,
    description: felt252,
    end_time: u64 
}

BetPlaced {
    market_id: u256,
    user: ContractAddress,
    amount: u256,
    prediction: u8
}

MarketResolved {
    market_id: u256,
    outcome: u8,
    resolution_time: u64,
    ai_validation_hash: felt252
}

RewardClaimed {
    market_id: u256,
    user: ContractAddress,
    amount: u256
}
```

## Development Setup

1. Install Dependencies:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

2. Build the Contract:
```bash
scarb build
```

3. Test the Contract:
```bash
scarb test
```

## Deployment

1. Declare the Contract:
```bash
starkli declare target/dev/ai_decision_market_DecisionMarket.contract_class.json
```

2. Deploy the Contract:
```bash
starkli deploy <CLASS_HASH>
```

## Security Considerations

- Market creators must provide valid AI validation hashes
- Only market creators can resolve their markets
- Markets can only be resolved after end time
- Rewards can only be claimed once per winning bet
- Users cannot bet on closed or resolved markets

## License

[Add your license information here] 