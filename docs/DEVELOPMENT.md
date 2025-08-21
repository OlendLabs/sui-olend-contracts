# Development Guide

This document provides guidelines for developing the Olend protocol.

## Prerequisites

- [Sui CLI](https://docs.sui.io/build/install) v1.14.2 or later
- [Move Analyzer](https://marketplace.visualstudio.com/items?itemName=move.move-analyzer) VS Code extension
- Git for version control

## Project Structure

```
olend/
├── sources/              # Move source code
│   ├── account.move     # Account management module
│   ├── oracle.move      # Oracle integration module
│   ├── liquidity.move   # Liquidity management module
│   ├── lending.move     # Lending operations module
│   ├── borrowing.move   # Borrowing operations module
│   ├── interest_rate.move # Interest rate calculations
│   └── liquidation_basic.move # Basic liquidation system
├── tests/               # Test files
├── scripts/             # Deployment and utility scripts
├── docs/                # Documentation
└── examples/            # Usage examples
```

## Development Workflow

### 1. Setup Development Environment

```bash
# Clone the repository
git clone <repository-url>
cd olend

# Verify Sui CLI installation
sui --version

# Build the project
sui move build
```

### 2. Running Tests

```bash
# Run all tests
./scripts/test.sh

# Run tests with coverage
sui move test --coverage

# Run specific module tests
sui move test --filter account
```

### 3. Code Quality Standards

#### Move Code Style
- Use 4 spaces for indentation
- Follow Sui Move naming conventions
- Add comprehensive documentation for all public functions
- Include error handling for all operations

#### Testing Requirements
- Minimum 95% code coverage
- Unit tests for all public functions
- Integration tests for cross-module interactions
- Property-based tests for mathematical functions

#### Error Handling
- Use custom error codes with descriptive names
- Group errors by module (1000-1099 for account, 1100-1199 for oracle, etc.)
- Provide detailed error messages for debugging

### 4. Module Development Guidelines

#### Account Management (`account.move`)
- Implement capability-based access control
- Track user positions across all protocol interactions
- Maintain account health factor calculations

#### Oracle Integration (`oracle.move`)
- Integrate with Pyth Network price feeds
- Implement price staleness validation
- Add circuit breaker mechanisms for price deviations

#### Liquidity Management (`liquidity.move`)
- Implement unified liquidity pools for capital efficiency
- Track liquidity utilization across lending and borrowing
- Optimize gas usage for liquidity operations

#### Lending System (`lending.move`)
- Implement YToken minting and burning
- Calculate exchange rates with interest accrual
- Integrate with unified liquidity management

#### Borrowing System (`borrowing.move`)
- Support single-asset borrowing pools initially
- Implement health factor calculations
- Track positions by health factor for efficient liquidation

#### Interest Rate Management (`interest_rate.move`)
- Implement kinked interest rate model
- Calculate compound interest with precision
- Update rates based on utilization

#### Liquidation System (`liquidation_basic.move`)
- Implement basic liquidation mechanics
- Calculate liquidation bonuses and penalties
- Support partial liquidations

### 5. Security Considerations

- Always validate input parameters
- Use capability-based access control
- Implement proper overflow/underflow protection
- Add comprehensive error handling
- Follow the principle of least privilege

### 6. Performance Optimization

- Minimize storage operations
- Use efficient data structures (Tables for O(1) lookups)
- Batch operations when possible
- Optimize gas usage for all functions

### 7. Documentation Requirements

- Document all public functions with clear descriptions
- Include parameter descriptions and return values
- Add usage examples for complex operations
- Maintain up-to-date API documentation

## Deployment

### Development Network (Devnet)

```bash
# Deploy to devnet
./scripts/deploy.sh devnet
```

### Test Network (Testnet)

```bash
# Deploy to testnet
./scripts/deploy.sh testnet
```

### Production Network (Mainnet)

```bash
# Deploy to mainnet (requires additional verification)
./scripts/deploy.sh mainnet
```

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Ensure Sui CLI is up to date
   - Check Move.toml configuration
   - Verify all dependencies are available

2. **Test Failures**
   - Check test data setup
   - Verify mock configurations
   - Ensure proper test isolation

3. **Deployment Issues**
   - Verify network configuration
   - Check gas budget settings
   - Ensure account has sufficient balance

### Getting Help

- Check the [Sui Documentation](https://docs.sui.io/)
- Review the specification documents in `.kiro/specs/olend-mvp/`
- Consult the Move language reference