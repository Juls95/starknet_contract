use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
struct MarketCreated {
    market_id: u256,
    creator: ContractAddress,
    description: felt252,
    end_time: u64,
}

#[derive(Drop, starknet::Event)]
struct BetPlaced {
    market_id: u256,
    user: ContractAddress,
    amount: u256,
    prediction: u8,
}

#[derive(Drop, starknet::Event)]
struct MarketResolved {
    market_id: u256,
    outcome: u8,
    resolution_time: u64,
    ai_validation_hash: felt252,
}

#[derive(Drop, starknet::Event)]
struct RewardClaimed {
    market_id: u256,
    user: ContractAddress,
    amount: u256,
}