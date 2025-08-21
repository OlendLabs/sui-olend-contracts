# Olend MVP - Decentralized Lending Protocol

Olend is a decentralized lending protocol built on the Sui blockchain that provides unified liquidity pools for lending and borrowing operations. The MVP focuses on creating a capital-efficient lending platform with advanced borrowing pools, oracle integration, account management, and liquidation mechanisms.

## Features

- **Unified Liquidity Management**: Capital-efficient cross-protocol liquidity sharing
- **Multi-Asset Support**: Support for various collateral types and borrowing assets
- **Dynamic Interest Rates**: Kinked interest rate model based on utilization
- **Advanced Liquidation**: Tick-based batch liquidation system
- **Oracle Integration**: Pyth Network price feeds with circuit breakers
- **Capability-Based Security**: Sui Move capability model for access control

## Project Structure

```
├── sources/           # Move source code
├── tests/            # Unit and integration tests
├── scripts/          # Deployment and utility scripts
├── docs/             # Documentation
├── examples/         # Usage examples
└── .kiro/specs/      # Feature specifications
```

## Development Setup

### Prerequisites

- [Sui CLI](https://docs.sui.io/build/install) installed
- [Move Analyzer](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) VS Code extension

### Building

```bash
sui move build
```

### Testing

```bash
sui move test
```

### Deployment

```bash
# Deploy to devnet
sui client publish --gas-budget 100000000

# Deploy to testnet
sui client publish --gas-budget 100000000 --network testnet
```

## Architecture

The protocol follows a modular architecture with the following core modules:

1. **Account Management** (`account.move`) - User account and capability management
2. **Oracle Integration** (`oracle.move`) - Price feed integration with Pyth Network
3. **Liquidity Management** (`liquidity.move`) - Unified liquidity pool management
4. **Lending System** (`lending.move`) - Deposit and withdrawal operations
5. **Borrowing System** (`borrowing.move`) - Collateralized borrowing operations
6. **Interest Rate Management** (`interest_rate.move`) - Dynamic rate calculations
7. **Liquidation System** (`liquidation_basic.move`) - Position liquidation mechanics

## Development Phases

### Phase 1 (P0 - Critical)
- Account Management System
- Oracle Integration
- Liquidity Management System
- Basic Lending System

### Phase 2 (P1 - High Priority)
- Single-Asset Borrowing Pools
- Dynamic Interest Rates
- Basic Liquidation

### Phase 3 (P2 - Medium Priority)
- Multi-Asset Borrowing Pools
- Tick-Based Batch Liquidation
- Advanced Repayment

### Phase 4 (P3 - Lower Priority)
- Fixed Interest Rates
- Looping Mechanisms
- Advanced Analytics

## Security

- Comprehensive error handling with custom error codes
- Capability-based access control
- Multi-signature governance for critical operations
- Circuit breakers for emergency situations
- 95% test coverage requirement

## Contributing

Please refer to the specification documents in `.kiro/specs/olend-mvp/` for detailed requirements and implementation guidelines.

## License

[License details here]