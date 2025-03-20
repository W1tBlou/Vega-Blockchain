# Versioned Upgradeable Smart Contract

This project implements a version control system for upgradeable smart contracts using the proxy pattern. It allows for upgrading and rolling back to previous versions of the implementation while maintaining state.

## Features

- Version history tracking
- Upgrade functionality
- Rollback capability
- Owner-based access control
- Comprehensive test coverage
- Deployment scripts

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Solidity ^0.8.20
- OpenZeppelin Contracts

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Install dependencies:
```bash
forge install
```

## Testing

Run the test suite:
```bash
forge test
```

For verbose output:
```bash
forge test -vv
```

## Deployment

1. Set up your environment variables:
```bash
export PRIVATE_KEY=your_private_key_here
```

2. Deploy to a network:
```bash
forge script script/Deploy.s.sol --rpc-url <your-rpc-url> --broadcast
```

## Contract Architecture

### VersionedProxy

The main proxy contract that:
- Maintains version history
- Handles upgrades and rollbacks
- Delegates calls to the current implementation
- Implements access control

### VersionedImplementation

The implementation contract that:
- Contains the business logic
- Is upgradeable
- Implements UUPS upgrade pattern

## Usage

### Upgrading

To upgrade to a new version:
```solidity
proxy.upgradeTo(newImplementationAddress);
```

### Rolling Back

To roll back to a previous version:
```solidity
proxy.rollbackTo(versionIndex);
```

### Getting Current Version

To get the current implementation address:
```solidity
address currentVersion = proxy.getCurrentVersion();
```

### Getting Version History

To get the complete version history:
```solidity
address[] memory history = proxy.getVersionHistory();
```

## Security Considerations

- Only the owner can upgrade or rollback
- Implementation addresses are validated
- Zero address checks are implemented
- Contract existence checks are performed

## License

MIT
