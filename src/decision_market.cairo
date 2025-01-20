use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
use core::zeroable::Zeroable;
use core::traits::Into;

// Import our types and events from crate root
use crate::types::{Market, Bet, Resolution};
use crate::events::{MarketCreated, BetPlaced, MarketResolved, RewardClaimed};

#[starknet::interface]
trait IDecisionMarket<TContractState> {
    fn create_market(ref self: TContractState, description: felt252, end_time: u64) -> u256;
    fn place_bet(ref self: TContractState, market_id: u256, prediction: u8, amount: u256);
    fn get_market_info(self: @TContractState, market_id: u256) -> Market;
    fn get_bet_info(self: @TContractState, market_id: u256, user: ContractAddress) -> Bet;
    fn resolve_market(ref self: TContractState, market_id: u256, outcome: u8, ai_validation_hash: felt252);
    fn claim_reward(ref self: TContractState, market_id: u256);
    fn get_resolution_info(self: @TContractState, market_id: u256) -> Resolution;
}

#[starknet::contract]
mod DecisionMarket {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use core::traits::Into;
    use super::{
        Market, Bet, Resolution,
        MarketCreated, BetPlaced, MarketResolved, RewardClaimed,
        IDecisionMarket
    };

    // Constants
    const MARKET_STATUS_OPEN: u8 = 1_u8;
    const MARKET_STATUS_CLOSED: u8 = 2_u8;
    const MARKET_STATUS_RESOLVED: u8 = 3_u8;

    #[storage]
    struct Storage {
        markets: LegacyMap<u256, Market>,
        bets: LegacyMap<(u256, ContractAddress), Bet>,
        market_count: u256,
        resolutions: LegacyMap<u256, Resolution>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        MarketCreated: MarketCreated,
        BetPlaced: BetPlaced,
        MarketResolved: MarketResolved,
        RewardClaimed: RewardClaimed,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.market_count.write(0);
    }

    #[abi(embed_v0)]
    impl DecisionMarketImpl of super::IDecisionMarket<ContractState> {
        fn create_market(ref self: ContractState, description: felt252, end_time: u64) -> u256 {
            let caller = get_caller_address();
            let market_id = self.market_count.read() + 1;
            self.market_count.write(market_id);

            let new_market = Market {
                creator: caller,
                description,
                end_time,
                total_stakes: 0,
                outcome: 0,
                status: MARKET_STATUS_OPEN,
            };
            self.markets.write(market_id, new_market);

            self.emit(Event::MarketCreated(MarketCreated { market_id, creator: caller, description, end_time }));
            market_id
        }

        fn place_bet(ref self: ContractState, market_id: u256, prediction: u8, amount: u256) {
            let caller = get_caller_address();
            let mut market = self.markets.read(market_id);
            assert(market.status == MARKET_STATUS_OPEN, 'Market closed');

            let bet = Bet { amount, prediction, claimed: false };
            self.bets.write((market_id, caller), bet);

            market.total_stakes += amount;
            self.markets.write(market_id, market);

            self.emit(Event::BetPlaced(BetPlaced { market_id, user: caller, amount, prediction }));
        }

        fn get_market_info(self: @ContractState, market_id: u256) -> Market {
            self.markets.read(market_id)
        }

        fn get_bet_info(self: @ContractState, market_id: u256, user: ContractAddress) -> Bet {
            self.bets.read((market_id, user))
        }

        fn resolve_market(ref self: ContractState, market_id: u256, outcome: u8, ai_validation_hash: felt252) {
            let mut market = self.markets.read(market_id);
            assert(market.status == MARKET_STATUS_OPEN, 'Market not open');
            assert(get_block_timestamp() >= market.end_time, 'Market not ended');
            assert(get_caller_address() == market.creator, 'Not authorized');

            let resolution = Resolution {
                resolved_outcome: outcome,
                resolution_time: get_block_timestamp(),
                ai_validation_hash,
                total_winning_stakes: 0, // This should be calculated in production
            };
            
            market.status = MARKET_STATUS_RESOLVED;
            market.outcome = outcome;
            
            self.markets.write(market_id, market);
            self.resolutions.write(market_id, resolution);
            
            self.emit(Event::MarketResolved(MarketResolved {
                market_id,
                outcome,
                resolution_time: get_block_timestamp(),
                ai_validation_hash,
            }));
        }

        fn claim_reward(ref self: ContractState, market_id: u256) {
            let caller = get_caller_address();
            let market = self.markets.read(market_id);
            let resolution = self.resolutions.read(market_id);
            let mut bet = self.bets.read((market_id, caller));
            
            assert(market.status == MARKET_STATUS_RESOLVED, 'Market not resolved');
            assert(!bet.claimed, 'Already claimed');
            assert(bet.prediction == resolution.resolved_outcome, 'Not a winner');
            
            let reward = bet.amount; // Simple 1:1 reward
            
            bet.claimed = true;
            self.bets.write((market_id, caller), bet);
            
            self.emit(Event::RewardClaimed(RewardClaimed {
                market_id,
                user: caller,
                amount: reward,
            }));
        }

        fn get_resolution_info(self: @ContractState, market_id: u256) -> Resolution {
            self.resolutions.read(market_id)
        }
    }
}