#!/bin/bash

# Olend Protocol Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK=${1:-devnet}
GAS_BUDGET=${2:-100000000}

echo -e "${GREEN}🚀 Deploying Olend Protocol to $NETWORK${NC}"

# Check if sui CLI is installed
if ! command -v sui &> /dev/null; then
    echo -e "${RED}❌ Sui CLI not found. Please install it first.${NC}"
    exit 1
fi

# Build the project
echo -e "${YELLOW}📦 Building project...${NC}"
sui move build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Run tests before deployment
echo -e "${YELLOW}🧪 Running tests...${NC}"
sui move test

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Tests failed${NC}"
    exit 1
fi

# Deploy to network
echo -e "${YELLOW}🌐 Deploying to $NETWORK...${NC}"

if [ "$NETWORK" = "mainnet" ]; then
    echo -e "${RED}⚠️  WARNING: Deploying to MAINNET${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
fi

# Execute deployment
sui client publish --gas-budget $GAS_BUDGET $([ "$NETWORK" != "devnet" ] && echo "--network $NETWORK")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}📋 Save the package ID and object IDs for future reference${NC}"
else
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi