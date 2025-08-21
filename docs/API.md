# Olend Protocol API Reference

This document provides a comprehensive reference for the Olend protocol's public API.

## Overview

The Olend protocol consists of several interconnected modules that provide decentralized lending and borrowing functionality on the Sui blockchain.

## Core Modules

### Account Management Module (`olend::account`)

Manages user accounts and positions across the protocol.

#### Types

```move
/// Global registry for all user accounts
public struct AccountRegistry has key

/// Individual user account with position tracking  
public struct Account has key

/// Non-transferable capability for account access
public struct AccountCap has key, store
```

#### Functions

```move
/// Create a new user account with capability
public fun create_account(ctx: &mut TxContext): (Account, AccountCap)

/// Get account health factor
public fun get_account_health(account: &Account): u64
```

### Oracle Integration Module (`olend::oracle`)

Provides price feed integration with external oracles.

#### Types

```move
/// Oracle price feed manager
public struct OracleRegistry has key

/// Price data with validation
public struct PriceData has copy, drop
```

#### Functions

```move
/// Get current price for asset type T
public fun get_price<T>(registry: &OracleRegistry): PriceData

/// Calculate USD value for given amount of asset T
public fun get_usd_value<T>(registry: &OracleRegistry, amount: u64): u64
```

### Liquidity Management Module (`olend::liquidity`)

Manages unified liquidity pools for capital efficiency.

#### Types

```move
/// Unified liquidity pool for cross-protocol asset management
public struct LiquidityPool<phantom T> has key

/// Individual liquidity provider position
public struct LiquidityPosition has store, copy, drop
```

#### Functions

```move
/// Add liquidity to the unified pool
public entry fun add_liquidity<T>(
    pool: &mut LiquidityPool<T>,
    deposit: Coin<T>,
    account: &mut Account,
    cap: &AccountCap,
    ctx: &mut TxContext
)

/// Remove liquidity from the unified pool
public entry fun remove_liquidity<T>(
    pool: &mut LiquidityPool<T>,
    shares_to_burn: u64,
    account: &mut Account,
    cap: &AccountCap,
    ctx: &mut TxContext
): Coin<T>
```

### Lending System Module (`olend::lending`)

Handles deposit and withdrawal operations with yield generation.

#### Types

```move
/// Unified liquidity pool for each asset type
public struct LendingPool<phantom T> has key

/// Yield-bearing token representing pool shares
public struct YToken<phantom T> has key, store
```

#### Functions

```move
/// Deposit assets and receive YTokens
public entry fun deposit<T>(
    pool: &mut LendingPool<T>,
    deposit_coin: Coin<T>,
    account: &mut Account,
    cap: &AccountCap,
    ctx: &mut TxContext
): YToken<T>

/// Withdraw assets by burning YTokens
public entry fun withdraw<T>(
    pool: &mut LendingPool<T>,
    ytoken: YToken<T>,
    account: &mut Account,
    cap: &AccountCap,
    ctx: &mut TxContext
): Coin<T>
```

### Borrowing System Module (`olend::borrowing`)

Manages collateralized borrowing operations.

#### Types

```move
/// Single collateral, single borrow asset pool
public struct BorrowingPool<phantom C, phantom T> has key

/// Borrowing position tracking
public struct Position has key
```

#### Functions

```move
/// Create a new borrowing pool
public fun create_pool<C, T>(
    collateral_factor: u64,
    liquidation_threshold: u64,
    ctx: &mut TxContext
): BorrowingPool<C, T>

/// Borrow assets against collateral
public fun borrow<C, T>(
    pool: &mut BorrowingPool<C, T>,
    collateral: YToken<C>,
    borrow_amount: u64,
    account: &mut Account,
    cap: &AccountCap,
    ctx: &mut TxContext
): (Coin<T>, Position)
```

### Interest Rate Module (`olend::interest_rate`)

Calculates dynamic interest rates based on utilization.

#### Types

```move
/// Kinked interest rate model implementation
public struct KinkedRateModel has store
```

#### Functions

```move
/// Calculate borrow rate based on utilization
public fun calculate_borrow_rate(model: &KinkedRateModel, utilization: u64): u64

/// Calculate supply rate for lenders
public fun calculate_supply_rate(borrow_rate: u64, utilization: u64, reserve_factor: u64): u64
```

### Liquidation System Module (`olend::liquidation_basic`)

Handles liquidation of underwater positions.

#### Types

```move
/// Liquidation engine for managing underwater positions
public struct LiquidationEngine has key

/// Liquidation event data
public struct LiquidationEvent has copy, drop
```

#### Functions

```move
/// Liquidate an underwater position
public fun liquidate_position<C, T>(
    engine: &mut LiquidationEngine,
    pool: &mut BorrowingPool<C, T>,
    position: &mut Position,
    repay_amount: u64,
    ctx: &mut TxContext
): LiquidationEvent

/// Check if a position is eligible for liquidation
public fun is_liquidatable(health_factor: u64, threshold: u64): bool
```

## Error Codes

The protocol uses standardized error codes organized by module:

- **1000-1099**: Account management errors
- **1100-1199**: Oracle integration errors  
- **1200-1299**: Lending system errors
- **1300-1399**: Borrowing system errors
- **1400-1499**: Liquidation system errors
- **1500-1599**: Mathematical calculation errors

## Usage Examples

### Basic Lending Flow

```move
// 1. Create account
let (account, cap) = account::create_account(ctx);

// 2. Deposit assets
let ytoken = lending::deposit<SUI>(
    &mut lending_pool,
    deposit_coin,
    &mut account,
    &cap,
    ctx
);

// 3. Withdraw assets
let withdrawn_coin = lending::withdraw<SUI>(
    &mut lending_pool,
    ytoken,
    &mut account,
    &cap,
    ctx
);
```

### Basic Borrowing Flow

```move
// 1. Deposit collateral (get YTokens from lending)
let collateral_ytoken = lending::deposit<SUI>(
    &mut lending_pool,
    collateral_coin,
    &mut account,
    &cap,
    ctx
);

// 2. Borrow against collateral
let (borrowed_coin, position) = borrowing::borrow<SUI, USDC>(
    &mut borrowing_pool,
    collateral_ytoken,
    borrow_amount,
    &mut account,
    &cap,
    ctx
);

// 3. Repay loan
repayment::repay<SUI, USDC>(
    &mut borrowing_pool,
    &mut position,
    repay_coin,
    &mut account,
    &cap,
    ctx
);
```

## Integration Guidelines

### Price Oracle Integration

The protocol integrates with Pyth Network for price feeds. Ensure proper price validation and staleness checks in your applications.

### Gas Optimization

- Batch operations when possible
- Use efficient data structures
- Minimize storage operations
- Consider transaction size limits

### Security Considerations

- Always validate user inputs
- Use capability-based access control
- Implement proper error handling
- Follow the principle of least privilege

## Support

For technical support and questions:
- Review the specification documents
- Check the development guide
- Consult the Move language documentation