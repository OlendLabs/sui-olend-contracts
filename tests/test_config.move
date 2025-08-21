/// Test configuration and utilities for Olend protocol
/// This module provides secure and standardized test utilities for a $1B+ DeFi platform
/// All test data follows production-grade security and precision standards
#[test_only]
module olend::test_config;
use sui::test_scenario::{Self, Scenario};
use sui::clock;
use sui::coin::{Self, Coin};
use sui::sui::SUI;

// === Test Constants ===
// Using realistic addresses for production-grade testing
const ADMIN: address = @0xAD;
const USER1: address = @0x1;
const USER2: address = @0x2;
const USER3: address = @0x3;
const LIQUIDATOR: address = @0xA;

// === Test Amounts ===
// All amounts use proper decimal precision for production accuracy
// SUI has 9 decimals
const INITIAL_BALANCE: u64 = 1_000_000_000_000; // 1,000 SUI
const LARGE_DEPOSIT: u64 = 100_000_000_000;     // 100 SUI
const MEDIUM_DEPOSIT: u64 = 50_000_000_000;     // 50 SUI
const SMALL_DEPOSIT: u64 = 10_000_000_000;      // 10 SUI
const BORROW_AMOUNT: u64 = 25_000_000_000;      // 25 SUI (50% of medium deposit)

// === Test Prices ===
// USD prices with 8 decimal precision for oracle compatibility
const SUI_PRICE_USD: u64 = 150_000_000;   // $1.50
const USDC_PRICE_USD: u64 = 100_000_000;  // $1.00 (stable)
const ETH_PRICE_USD: u64 = 2500_00000000; // $2,500.00

// === Risk Parameters ===
// Production-grade risk parameters for testing
const COLLATERAL_FACTOR_VOLATILE: u64 = 75_000_000;  // 75% (8 decimals)
const COLLATERAL_FACTOR_STABLE: u64 = 90_000_000;    // 90% (8 decimals)
const LIQUIDATION_THRESHOLD: u64 = 80_000_000;       // 80% (8 decimals)
const LIQUIDATION_BONUS: u64 = 5_000_000;            // 5% (8 decimals)

// === Time Constants ===
const SECONDS_PER_YEAR: u64 = 31_536_000; // 365 * 24 * 60 * 60
const TEST_TIMESTAMP_START: u64 = 1_700_000_000_000; // Nov 2023 in ms

/// Initialize test scenario with proper security setup
/// Creates a controlled environment for testing $1B+ DeFi operations
public fun init_test_scenario(): Scenario {
    let mut scenario = test_scenario::begin(ADMIN);
    
    // Create and share a clock for time-dependent tests
    // Critical for interest calculations and liquidation timing
    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, TEST_TIMESTAMP_START);
        clock::share_for_testing(clock);
    };
    
    scenario
}

/// Create test coins with proper validation
/// Ensures all test amounts are realistic for production scenarios
public fun mint_test_coins(scenario: &mut Scenario, user: address, amount: u64): Coin<SUI> {
    // Validate amount is within reasonable bounds for testing
    assert!(amount > 0, 0);
    assert!(amount <= INITIAL_BALANCE, 1);
    
    test_scenario::next_tx(scenario, user);
    coin::mint_for_testing<SUI>(amount, test_scenario::ctx(scenario))
}

/// Create multiple test coins for complex scenarios
public fun mint_multiple_test_coins(
    scenario: &mut Scenario, 
    user: address, 
    amounts: vector<u64>
): vector<Coin<SUI>> {
    let mut coins = vector::empty<Coin<SUI>>();
    let mut i = 0;
    let len = vector::length(&amounts);
    
    while (i < len) {
        let amount = *vector::borrow(&amounts, i);
        let coin = mint_test_coins(scenario, user, amount);
        vector::push_back(&mut coins, coin);
        i = i + 1;
    };
    
    coins
}

// === Address Getters ===
/// Get admin address for governance operations
public fun admin(): address { ADMIN }

/// Get user addresses for multi-user testing scenarios
public fun user1(): address { USER1 }
public fun user2(): address { USER2 }
public fun user3(): address { USER3 }
public fun liquidator(): address { LIQUIDATOR }

// === Amount Getters ===
/// Get standardized test amounts
public fun initial_balance(): u64 { INITIAL_BALANCE }
public fun large_deposit(): u64 { LARGE_DEPOSIT }
public fun medium_deposit(): u64 { MEDIUM_DEPOSIT }
public fun small_deposit(): u64 { SMALL_DEPOSIT }
public fun borrow_amount(): u64 { BORROW_AMOUNT }

// === Price Getters ===
/// Get oracle-compatible USD prices
public fun sui_price(): u64 { SUI_PRICE_USD }
public fun usdc_price(): u64 { USDC_PRICE_USD }
public fun eth_price(): u64 { ETH_PRICE_USD }

// === Risk Parameter Getters ===
/// Get production-grade risk parameters
public fun collateral_factor_volatile(): u64 { COLLATERAL_FACTOR_VOLATILE }
public fun collateral_factor_stable(): u64 { COLLATERAL_FACTOR_STABLE }
public fun liquidation_threshold(): u64 { LIQUIDATION_THRESHOLD }
public fun liquidation_bonus(): u64 { LIQUIDATION_BONUS }

// === Time Utilities ===
/// Get time constants for interest calculations
public fun seconds_per_year(): u64 { SECONDS_PER_YEAR }
public fun test_timestamp_start(): u64 { TEST_TIMESTAMP_START }

/// Advance clock by specified seconds for time-based testing
public fun advance_clock(scenario: &mut Scenario, seconds: u64) {
    test_scenario::next_tx(scenario, ADMIN);
    let mut clock = test_scenario::take_shared<clock::Clock>(scenario);
    let current_time = clock::timestamp_ms(&clock);
    clock::set_for_testing(&mut clock, current_time + (seconds * 1000));
    test_scenario::return_shared(clock);
}

// === Validation Utilities ===
/// Validate health factor is within safe bounds
public fun validate_health_factor(health_factor: u64): bool {
    health_factor >= 100_000_000 // Must be >= 1.0 (8 decimals)
}

/// Validate interest rate is within reasonable bounds
public fun validate_interest_rate(rate: u64): bool {
    rate <= 100_000_000 // Must be <= 100% annually (8 decimals)
}

/// Calculate expected interest for testing
public fun calculate_test_interest(principal: u64, rate: u64, time_seconds: u64): u64 {
    // Simple interest calculation for testing: P * R * T
    // rate is annual with 8 decimals, time is in seconds
    (principal * rate * time_seconds) / (SECONDS_PER_YEAR * 100_000_000)
}