use starknet::ContractAddress;

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Market {
    creator: ContractAddress,
    description: felt252,
    end_time: u64,
    total_stakes: u256,
    outcome: u8,
    status: u8,
}

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Bet {
    amount: u256,
    prediction: u8,
    claimed: bool,
}

#[derive(Drop, Serde, Copy, starknet::Store)]
struct Resolution {
    resolved_outcome: u8,
    resolution_time: u64,
    ai_validation_hash: felt252,
    total_winning_stakes: u256,
}