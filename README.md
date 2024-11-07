# MyToken - ERC-721-like NFT Contract

This contract simulates an **ERC-721** non-fungible token (NFT), implementing functionalities such as token creation, contract ownership transfer, and authorized addresses for token minting. This project is developed using **Solidity** and tested with **Truffle**.

## Implemented Features

- **Token Minting**: Only authorized addresses can mint tokens, and each minted token is unique.
- **Contract Ownership**: The ownership of the contract can be transferred between addresses.
- **Minter Authorization**: Specific addresses can be authorized to mint tokens (not just the contract owner).
- **Token Ownership Check**: Functions to check the owner of a token and whether an address owns a specific token.
- **Events**: Emission of events for `Transfer`, `OwnershipTransferred`, `TokenMinted`, `MinterAuthorized`, and `MinterRevoked`.

## Requirements

- **Node.js** (recommended version >=12)
- **Truffle** (development framework for smart contracts)
- **Ganache** (for simulating an Ethereum network locally during tests)

## Installation

### 1. Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/seu-usuario/MyToken.git
cd MyToken
```

### 2. Install Dependencies

Within the project directory, install the dependencies using `npm` (or `yarn`):

```bash
npm install
```
Or, if you prefer to use `yarn`:

```bash
npm install
```

### 3. Set Up Truffle

The project already has the basic Truffle setup. To initialize it, just run the following commands:

```bash
truffle init
```

### 4. Compile the Contract

After setting up Truffle, compile the contract using the following command:

```bash
truffle compile
```

### 5. Run Tests

Once the contract is compiled, you can run the tests to verify that all functionalities are working as expected.

First, start a local network with Ganache (if you're not using a real Ethereum network or a testnet).

To run the tests, use:

```bash
truffle test
```

This will run the tests defined in the `test` folder of the project.

## Project Structure

The project has the following structure:

```bash
MyToken/
├── contracts/           # Contains the smart contract source code
│   └── MyToken.sol      # The ERC-721-like smart contract
├── migrations/          # Migration files for Truffle
│   └── 1_deploy_contracts.js
├── test/                # Smart contract test files
│   └── MyToken.test.js  # Unit tests with Truffle
├── truffle-config.js    # Truffle configuration
└── README.md            # This documentation file
```

## Contributing

If you'd like to contribute to this project, follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or fix: `git checkout -b my-feature`
3. Make the necessary changes and add tests to cover your changes.
4. Commit your changes following the GitFlow convention.
5. Push your branch to GitHub.