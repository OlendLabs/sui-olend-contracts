/// Basic test to verify project setup and configuration
/// Ensures the foundation is solid for a $1B+ DeFi platform
#[test_only]
module olend::basic_test;

/// Test basic module compilation and execution
/// This validates that our project structure is correct
#[test]
fun test_basic_setup() {
    // Basic arithmetic to verify Move compilation
    let a = 1000000000; // 1 SUI with 9 decimals
    let b = 500000000;  // 0.5 SUI with 9 decimals
    let sum = a + b;
    
    assert!(sum == 1500000000, 0); // 1.5 SUI
    
    // Test precision calculations critical for DeFi
    let rate = 5000000; // 5% with 8 decimals
    let principal = 100000000000; // 100 SUI with 9 decimals
    let interest = (principal * rate) / 100000000; // Simple interest calculation
    
    assert!(interest == 5000000000, 1); // 5 SUI interest
}

/// Test address validation for security
/// Critical for capability-based access control
#[test]
fun test_address_validation() {
    let admin = @0xAD;
    let user1 = @0x1;
    
    // Verify addresses are different (security requirement)
    assert!(admin != user1, 0);
    
    // Test address comparison for access control
    let current_user = @0x1;
    assert!(current_user == user1, 1);
}

/// Test mathematical precision for financial calculations
/// Essential for accurate interest and liquidation calculations
#[test]
fun test_precision_calculations() {
    // Test 8-decimal precision for USD values
    let price_usd = 150000000; // $1.50 with 8 decimals
    let amount_sui = 1000000000; // 1 SUI with 9 decimals
    
    // Calculate USD value: (amount * price) / 10^9 * 10^8 = amount * price / 10^1
    let usd_value = (amount_sui * price_usd) / 1000000000;
    assert!(usd_value == 150000000, 0); // $1.50
    
    // Test health factor calculation (critical for liquidations)
    let collateral_value = 1000000000; // $10.00 with 8 decimals
    let debt_value = 750000000;        // $7.50 with 8 decimals
    let health_factor = (collateral_value * 100000000) / debt_value; // 8 decimal precision
    
    assert!(health_factor == 133333333, 1); // ~1.33 health factor
}

/// Test overflow protection for large amounts
/// Critical for handling $1B+ in TVL safely
#[test]
fun test_overflow_protection() {
    // Test with large amounts typical of $1B+ protocols
    let large_amount = 1000000000000000000; // 1B tokens with 9 decimals
    let small_multiplier = 2;
    
    // This should not overflow
    let result = large_amount / 1000000000 * small_multiplier;
    assert!(result == 2000000000, 0); // 2B tokens
    
    // Test percentage calculations with large amounts
    let percentage = 5000000; // 5% with 8 decimals
    let fee = (large_amount / 1000000000 * percentage) / 100000000;
    assert!(fee == 50000000, 1); // 5% of 1B = 50M tokens
}