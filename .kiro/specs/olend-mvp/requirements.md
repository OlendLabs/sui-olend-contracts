# Olend MVP Requirements Document

## Introduction

Olend is a decentralized lending protocol built on the Sui blockchain that provides unified liquidity pools for lending and borrowing operations. The MVP focuses on creating a capital-efficient lending platform with advanced borrowing pools, oracle integration, account management, and liquidation mechanisms. The platform supports both fixed and floating interest rates, multiple collateral types, and implements a tick-based batch liquidation system inspired by Uniswap v3.

## Development Phases and Priorities

### Phase 1 (MVP Core - Highest Priority)
- **P0 (Critical)**: Account Management System, Oracle Integration, Basic Lending System
- **P1 (High)**: Single-Asset Borrowing Pools, Dynamic Interest Rates, Basic Liquidation

### Phase 2 (Enhanced Features - Medium Priority)  
- **P2 (Medium)**: Multi-Asset Borrowing Pools, Tick-Based Batch Liquidation, Advanced Repayment

### Phase 3 (Advanced Features - Lower Priority)
- **P3 (Low)**: Fixed Interest Rates, Looping Mechanisms, Advanced Analytics

## Dependency Matrix

```
Account System (P0) → Oracle Integration (P0) → Lending System (P0) → Borrowing Pools (P1) → Liquidation (P1) → Multi-Asset Pools (P2) → Advanced Features (P3)
```

## Technical Architecture Requirements

### Move Language Specifications
- All modules must follow Sui Move standards and best practices
- Implement comprehensive error handling with custom error codes
- Use capability-based security model with proper access controls
- Optimize for gas efficiency and transaction batching
- Support hot potato pattern for atomic operations

### Testing Requirements
- Minimum 95% code coverage for all public functions
- Unit tests for each module with positive and negative test cases
- Integration tests for cross-module interactions
- Property-based testing for mathematical calculations
- Stress testing for liquidation scenarios

### Security Requirements
- Multi-signature governance for critical parameter changes
- Time-locked upgrades for protocol modifications
- Circuit breakers for emergency situations
- Formal verification for core mathematical functions
- Regular security audits and bug bounty programs

## Requirements

### Requirement 1: Account Management System (P0 - Foundation)

**User Story:** As a platform user, I want a secure account system that manages my identity and positions so that I can safely interact with all protocol features.

**Priority:** P0 (Critical) - Must be implemented first as foundation for all other features
**Dependencies:** None (foundational requirement)
**Module:** account.move

#### Acceptance Criteria

1. WHEN the protocol initializes THEN the system SHALL create AccountRegistry as a shared object with proper access controls
2. WHEN a new user joins THEN the system SHALL create Account (shared) and AccountCap (owned) objects with unique identifiers
3. WHEN user performs any protocol operation THEN the system SHALL validate AccountCap ownership and permissions
4. WHEN account data changes THEN the system SHALL update AccountRegistry with versioned position tracking
5. IF AccountCap is transferred or lost THEN the system SHALL prevent unauthorized access to associated Account
6. WHEN account queries occur THEN the system SHALL provide read-only access to account statistics and position summaries
7. IF account operations fail THEN the system SHALL emit detailed error events with error codes for debugging

#### Technical Specifications

- AccountRegistry: Global shared object storing all user accounts and cross-references
- Account: Per-user shared object containing lending positions, borrowing positions, rewards, and metadata
- AccountCap: Non-transferable capability object for account access control
- Support for account-level position aggregation and risk calculation
- Event emission for all account state changes

### Requirement 2: Oracle Price Integration (P0 - Foundation)

**User Story:** As a platform participant, I want reliable and accurate asset pricing so that all financial calculations are based on current market values.

**Priority:** P0 (Critical) - Required for all price-dependent operations
**Dependencies:** Account Management System
**Module:** oracle.move

#### Acceptance Criteria

1. WHEN the system needs asset prices THEN it SHALL query Pyth Network oracle with proper error handling
2. WHEN price data is retrieved THEN the system SHALL validate price freshness within configurable time windows
3. WHEN price feeds are unavailable THEN the system SHALL gracefully handle failures and prevent operations
4. WHEN calculating USD values THEN the system SHALL apply proper decimal scaling and precision handling
5. IF price deviation exceeds safety thresholds THEN the system SHALL trigger circuit breakers
6. WHEN multiple price sources exist THEN the system SHALL implement price aggregation with outlier detection
7. WHEN price updates occur THEN the system SHALL emit price change events for monitoring

#### Technical Specifications

- Integration with Pyth Network price feeds
- Configurable price staleness thresholds (default: 60 seconds)
- Support for multiple price feed sources with fallback mechanisms
- Price validation and sanity checks
- Decimal precision handling for different asset types

### Requirement 3: Unified Lending System (P0 - Core)

**User Story:** As a lender, I want to deposit assets into unified liquidity pools so that I can earn yield while providing maximum capital efficiency across the platform.

**Priority:** P0 (Critical) - Core lending functionality
**Dependencies:** Account Management System, Oracle Integration
**Module:** lending.move

#### Acceptance Criteria

1. WHEN a user deposits assets THEN the system SHALL mint YTokens representing proportional pool ownership
2. WHEN calculating YToken amounts THEN the system SHALL use current exchange rates including accrued interest
3. WHEN a user withdraws assets THEN the system SHALL burn YTokens and transfer underlying assets plus earned interest
4. WHEN multiple users deposit same asset type THEN the system SHALL aggregate into unified liquidity pools
5. IF withdrawal exceeds available liquidity THEN the system SHALL reject transaction with specific error codes
6. WHEN interest accrues THEN the system SHALL update exchange rates for all YToken holders proportionally
7. WHEN pool utilization changes THEN the system SHALL recalculate supply interest rates dynamically
8. IF emergency conditions occur THEN the system SHALL support withdrawal pausing with governance controls

#### Technical Specifications

- YToken<T>: Yield-bearing token representing pool shares with rebasing mechanism
- LendingPool<T>: Unified liquidity pool for each asset type with interest rate models
- Exchange rate calculation: (total_underlying + accrued_interest) / total_ytokens
- Support for multiple asset types with independent interest rate curves
- Gas-optimized batch operations for multiple deposits/withdrawals

### Requirement 4: Single-Asset Borrowing Pools (P1 - High Priority)

**User Story:** As a borrower, I want to use my deposited assets as collateral to borrow different assets so that I can access liquidity while maintaining my positions.

**Priority:** P1 (High) - Core borrowing functionality
**Dependencies:** Account Management, Oracle Integration, Unified Lending System
**Module:** borrowing.move

#### Acceptance Criteria

1. WHEN creating BorrowingPool<C, T> THEN the system SHALL validate that collateral type C ≠ borrowing type T
2. WHEN setting collateralization ratios THEN the system SHALL enforce maximum 90% for volatile assets and 95% for wrapped/stable assets
3. WHEN a user borrows THEN the system SHALL require YToken<C> collateral from lending pools
4. WHEN calculating borrowing capacity THEN the system SHALL use oracle prices and collateralization ratios
5. IF user has existing position THEN the system SHALL update existing position atomically
6. IF user has no position THEN the system SHALL create new borrowing position with proper initialization
7. WHEN borrowing occurs THEN the system SHALL transfer borrowed assets from lending pools to user
8. IF insufficient liquidity exists THEN the system SHALL reject borrowing with detailed error messages

#### Technical Specifications

- BorrowingPool<C, T>: Single collateral, single borrow asset pool
- Position tracking with collateral amounts, borrowed amounts, and interest accrual
- Atomic position updates with proper error handling
- Integration with lending pools for liquidity management
- Support for multiple pools with same asset pairs but different parameters

### Requirement 5: Multi-Asset Borrowing Pools (P2 - Medium Priority)

**User Story:** As an advanced borrower, I want to use multiple collateral types and borrow multiple assets simultaneously so that I can optimize my capital efficiency.

**Priority:** P2 (Medium) - Enhanced borrowing features for v2
**Dependencies:** Single-Asset Borrowing Pools, Advanced Position Management
**Module:** borrowing_multi.move

#### Acceptance Criteria

1. WHEN creating BorrowingPool2<C, T1, T2> THEN the system SHALL support single collateral with dual borrowing assets
2. WHEN creating BorrowingPool4<C1, C2, T1, T2> THEN the system SHALL support dual collateral with dual borrowing assets
3. WHEN calculating total collateral value THEN the system SHALL aggregate all collateral types using oracle prices
4. WHEN calculating borrowing capacity THEN the system SHALL consider combined collateral value and individual asset limits
5. IF any collateral type equals any borrowing type THEN the system SHALL reject pool creation
6. WHEN managing positions THEN the system SHALL track all collateral and borrowing assets independently
7. WHEN liquidation occurs THEN the system SHALL consider all assets in risk calculations

#### Technical Specifications

- BorrowingPool2<C, T1, T2>: Single collateral, dual borrow assets (v2 implementation)
- BorrowingPool4<C1, C2, T1, T2>: Dual collateral, dual borrow assets (v2 implementation)
- Complex position management with multiple asset tracking
- Advanced risk calculations for multi-asset scenarios

### Requirement 6: Dynamic Interest Rate Management (P1 - High Priority)

**User Story:** As a platform participant, I want interest rates to adjust dynamically based on utilization so that the protocol maintains optimal liquidity and fair pricing.

**Priority:** P1 (High) - Essential for sustainable economics
**Dependencies:** Unified Lending System, Single-Asset Borrowing Pools
**Module:** interest_rate.move

#### Acceptance Criteria

1. WHEN utilization rate changes THEN the system SHALL recalculate floating interest rates using kinked rate models
2. WHEN utilization < optimal rate THEN the system SHALL apply base rate + (utilization / optimal) * slope1
3. WHEN utilization > optimal rate THEN the system SHALL apply base rate + slope1 + ((utilization - optimal) / (1 - optimal)) * slope2
4. WHEN interest accrues THEN the system SHALL compound interest using precise mathematical formulas
5. WHEN borrowing or repayment occurs THEN the system SHALL update interest rates immediately
6. IF rate parameters need updates THEN the system SHALL require governance approval with time delays
7. WHEN calculating supply rates THEN the system SHALL apply formula: borrow_rate * utilization * (1 - reserve_factor)

#### Technical Specifications

- Kinked interest rate model with configurable parameters:
  - Base rate: 0-5% annually
  - Optimal utilization: 80-90% depending on asset
  - Slope1: 0-20% annually
  - Slope2: 50-300% annually
- Compound interest calculation with per-second precision
- Reserve factor for protocol revenue (5-25% of interest)
- Gas-optimized rate calculations

### Requirement 7: Fixed Interest Rate System (P3 - Lower Priority)

**User Story:** As a borrower seeking predictable costs, I want access to fixed-rate borrowing so that I can plan my financial obligations with certainty.

**Priority:** P3 (Low) - Advanced feature for v2
**Dependencies:** Dynamic Interest Rate Management, Advanced Pool Management
**Module:** fixed_rate.move

#### Acceptance Criteria

1. WHEN creating fixed-rate pools THEN the system SHALL allow platform operators to set immutable rates
2. WHEN first borrowing occurs in fixed-rate pool THEN the system SHALL permanently lock the interest rate
3. WHEN managing fixed-rate positions THEN the system SHALL calculate interest using locked rates
4. IF fixed-rate pool has no borrowers THEN the system SHALL allow rate modifications by governance
5. WHEN comparing rates THEN the system SHALL display both fixed and floating options to users

### Requirement 8: Collateralized Borrowing Operations (P1 - High Priority)

**User Story:** As a borrower, I want to provide collateral and borrow assets based on oracle prices so that I can access liquidity without selling my holdings.

**Priority:** P1 (High) - Core borrowing mechanics
**Dependencies:** Account Management, Oracle Integration, Single-Asset Borrowing Pools, Interest Rate Management
**Module:** borrowing_operations.move

#### Acceptance Criteria

1. WHEN a user initiates borrowing THEN the system SHALL validate AccountCap ownership and permissions
2. WHEN calculating collateral value THEN the system SHALL use current oracle prices with proper decimal handling
3. WHEN determining borrowing capacity THEN the system SHALL apply formula: (collateral_value * collateral_ratio) - existing_debt
4. WHEN borrowing occurs THEN the system SHALL transfer YToken<C> collateral to borrowing pool custody
5. IF user has no existing position THEN the system SHALL create new BorrowingPosition with initialization timestamp
6. IF user has existing position THEN the system SHALL update position atomically with interest accrual
7. WHEN position is created/updated THEN the system SHALL organize by collateralization ratio groups for efficient liquidation
8. IF borrowing would exceed capacity THEN the system SHALL reject with specific error code and available capacity info

#### Technical Specifications

- BorrowingPosition struct with collateral amounts, borrowed amounts, interest rates, and timestamps
- Atomic position updates with proper rollback on failures
- Collateralization ratio grouping for batch liquidation efficiency
- Integration with account system for position tracking
- Gas-optimized calculations with overflow protection

### Requirement 9: Flexible Repayment System (P1 - High Priority)

**User Story:** As a borrower, I want to repay my loans partially or fully with automatic interest calculation so that I can manage my debt positions flexibly.

**Priority:** P1 (High) - Essential for borrowing lifecycle
**Dependencies:** Collateralized Borrowing Operations, Interest Rate Management
**Module:** repayment.move

#### Acceptance Criteria

1. WHEN user initiates repayment THEN the system SHALL calculate total debt including accrued interest up to current timestamp
2. WHEN calculating interest THEN the system SHALL use compound interest formula: principal * (1 + rate)^time
3. WHEN partial repayment occurs THEN the system SHALL update position with new principal and reset interest calculation timestamp
4. WHEN full repayment occurs THEN the system SHALL delete position and return all collateral to user
5. IF repayment amount exceeds total debt THEN the system SHALL process exact debt amount and return excess to user
6. WHEN repayment is processed THEN the system SHALL update borrowing pool liquidity and position tracking
7. WHEN collateral is released THEN the system SHALL transfer YTokens back to user's account
8. IF repayment fails THEN the system SHALL maintain original position state with proper error reporting

#### Technical Specifications

- Precise interest calculation with overflow protection
- Atomic repayment operations with proper state management
- Support for partial and full repayment scenarios
- Collateral release mechanisms with proper validation
- Integration with pool liquidity management

### Requirement 10: Basic Liquidation System (P1 - High Priority)

**User Story:** As a protocol participant, I want underwater positions to be liquidated efficiently so that the protocol maintains solvency and lenders are protected.

**Priority:** P1 (High) - Critical for protocol safety
**Dependencies:** Collateralized Borrowing Operations, Oracle Integration, Repayment System
**Module:** liquidation_basic.move

#### Acceptance Criteria

1. WHEN position health factor falls below 1.0 THEN the system SHALL mark position as liquidatable
2. WHEN liquidation is triggered THEN the system SHALL calculate health factor as: (collateral_value * liquidation_threshold) / total_debt
3. WHEN liquidating THEN the system SHALL allow liquidators to repay up to 50% of debt in single transaction
4. WHEN liquidation occurs THEN the system SHALL transfer collateral to liquidator with liquidation bonus (5-10%)
5. IF liquidation improves health factor above 1.0 THEN the system SHALL allow position to remain active
6. WHEN liquidation completes THEN the system SHALL update position state and pool records
7. IF position becomes fully liquidated THEN the system SHALL close position and handle any remaining collateral

#### Technical Specifications

- Health factor calculation with precise decimal arithmetic
- Liquidation bonus configuration per asset type
- Support for partial liquidations to maintain protocol stability
- Integration with DeepBook for collateral disposal (future enhancement)
- Gas-optimized liquidation operations

### Requirement 11: Tick-Based Batch Liquidation (P2 - Medium Priority)

**User Story:** As a liquidator, I want to efficiently liquidate multiple risky positions simultaneously with minimal penalties so that I can maximize efficiency while maintaining protocol health.

**Priority:** P2 (Medium) - Advanced liquidation optimization
**Dependencies:** Basic Liquidation System, Advanced Position Management
**Module:** liquidation_batch.move

#### Acceptance Criteria

1. WHEN multiple positions reach similar liquidation thresholds THEN the system SHALL group them into price-based ticks
2. WHEN batch liquidation occurs THEN the system SHALL process all positions within same tick simultaneously
3. WHEN calculating liquidation penalties THEN the system SHALL apply reduced penalties (0.1-1%) for batch operations
4. WHEN liquidation assets are processed THEN the system SHALL create optimized DeepBook orders with market-making incentives
5. IF batch liquidation improves overall protocol health THEN the system SHALL prioritize batch operations over individual liquidations
6. WHEN tick boundaries are crossed THEN the system SHALL automatically trigger batch liquidation processes
7. WHEN liquidation completes THEN the system SHALL update all affected positions and redistribute proceeds efficiently

#### Technical Specifications

- Tick-based position organization inspired by Uniswap v3
- Batch processing with gas optimization
- Integration with DeepBook for efficient asset disposal
- Reduced liquidation penalties for batch operations
- Automated tick boundary monitoring

### Requirement 12: Borrowing Term Management (P2 - Medium Priority)

**User Story:** As a borrower, I want to choose between indefinite and fixed-term borrowing so that I can select the loan structure that best fits my financial planning needs.

**Priority:** P2 (Medium) - Enhanced borrowing options
**Dependencies:** Flexible Repayment System, Advanced Position Management
**Module:** term_management.move

#### Acceptance Criteria

1. WHEN creating indefinite-term positions THEN the system SHALL allow borrowing without expiration constraints
2. WHEN managing indefinite positions THEN the system SHALL maintain positions as long as health factors remain above liquidation thresholds
3. WHEN implementing fixed-term borrowing (v2) THEN the system SHALL enforce specific maturity dates with automatic liquidation
4. IF collateral value drops below safety thresholds THEN the system SHALL trigger liquidation regardless of term structure
5. WHEN term conditions change THEN the system SHALL update position metadata and notify relevant parties
6. WHEN fixed-term loans mature THEN the system SHALL automatically initiate repayment or liquidation processes
7. IF borrowers want to extend terms THEN the system SHALL allow term modifications with proper governance approval

#### Technical Specifications

- Support for indefinite-term borrowing in MVP
- Fixed-term borrowing framework for v2 implementation
- Automated term monitoring and enforcement
- Integration with liquidation systems for term-based triggers

### Requirement 13: Revenue Distribution System (P2 - Medium Priority)

**User Story:** As a stakeholder, I want transparent and automated revenue distribution so that all parties receive appropriate compensation and the protocol maintains adequate reserves.

**Priority:** P2 (Medium) - Sustainable tokenomics
**Dependencies:** Interest Rate Management, Protocol Operations
**Module:** revenue.move

#### Acceptance Criteria

1. WHEN protocol generates interest revenue THEN the system SHALL automatically allocate 10% to development team treasury
2. WHEN protocol generates interest revenue THEN the system SHALL automatically allocate 10% to insurance/risk fund
3. WHEN protocol generates liquidation fees THEN the system SHALL distribute according to predefined allocation ratios
4. WHEN revenue distribution occurs THEN the system SHALL emit detailed events for transparency and accounting
5. IF risk events occur THEN the system SHALL automatically utilize risk fund assets for loss compensation
6. WHEN risk fund is insufficient THEN the system SHALL trigger emergency protocols and governance intervention
7. WHEN revenue parameters need adjustment THEN the system SHALL require multi-signature governance approval

#### Technical Specifications

- Automated revenue collection and distribution mechanisms
- Multi-signature treasury management for development funds
- Insurance fund management with automated loss compensation
- Transparent accounting with detailed event emission
- Governance integration for parameter adjustments

### Requirement 14: Looping Mechanisms (P3 - Lower Priority)

**User Story:** As an advanced user, I want to create leveraged positions through automated borrowing and re-depositing so that I can amplify my exposure to specific assets.

**Priority:** P3 (Low) - Advanced feature for v2
**Dependencies:** Multi-Asset Borrowing Pools, Advanced Position Management
**Module:** looping.move

#### Acceptance Criteria

1. WHEN user initiates looping THEN the system SHALL automatically borrow against collateral and re-deposit borrowed assets
2. WHEN calculating loop iterations THEN the system SHALL respect maximum leverage limits and gas constraints
3. WHEN managing looped positions THEN the system SHALL track complex position relationships and dependencies
4. IF market conditions change THEN the system SHALL provide automated de-leveraging options
5. WHEN unwinding loops THEN the system SHALL execute operations in proper sequence to maintain position health
6. WHEN loop operations fail THEN the system SHALL provide partial execution results and clear error states

#### Technical Specifications

- Automated multi-step transaction execution
- Leverage calculation and risk management
- Complex position tracking with dependency management
- Gas optimization for multi-step operations

## Implementation Roadmap

### Phase 1 (MVP - 8-12 weeks)
1. **Week 1-2**: Account Management System (P0)
2. **Week 2-3**: Oracle Integration (P0) 
3. **Week 3-5**: Unified Lending System (P0)
4. **Week 5-7**: Single-Asset Borrowing Pools (P1)
5. **Week 7-8**: Dynamic Interest Rates (P1)
6. **Week 8-10**: Collateralized Borrowing Operations (P1)
7. **Week 10-11**: Flexible Repayment System (P1)
8. **Week 11-12**: Basic Liquidation System (P1)

### Phase 2 (Enhanced Features - 6-8 weeks)
1. **Week 13-15**: Multi-Asset Borrowing Pools (P2)
2. **Week 15-17**: Tick-Based Batch Liquidation (P2)
3. **Week 17-19**: Borrowing Term Management (P2)
4. **Week 19-20**: Revenue Distribution System (P2)

### Phase 3 (Advanced Features - 4-6 weeks)
1. **Week 21-23**: Fixed Interest Rate System (P3)
2. **Week 23-26**: Looping Mechanisms (P3)
