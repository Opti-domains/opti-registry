## Opti.domains Singular Registry

**A modular and customizable ENS V2-like style recursive registry**

## Deployments

### OP Mainnet

- Implementation Logic: [0x34A860765ED7893d390FE1E3db63f4635effFeC5](https://optimistic.etherscan.io/address/0x34A860765ED7893d390FE1E3db63f4635effFeC5)
- Implementation Proxy: [0x30Cf371bB8b655a6FabB69B040CCF28Fb7B2A098](https://optimistic.etherscan.io/address/0x30Cf371bB8b655a6FabB69B040CCF28Fb7B2A098)
- Resolver Logic: [0x64075e0175F1393DDeDa38d0577653872169Ffc0](https://optimistic.etherscan.io/address/0x64075e0175F1393DDeDa38d0577653872169Ffc0)
- Resolver Proxy: [0x16Af4Cb44e812075e108a95A5A9C7440D15c9B5D](https://optimistic.etherscan.io/address/0x16Af4Cb44e812075e108a95A5A9C7440D15c9B5D)
- Root: [0x5b2fB670234E52Cb735d759dAe11c9BeF7bEd01e](https://optimistic.etherscan.io/address/0x5b2fB670234E52Cb735d759dAe11c9BeF7bEd01e)
- ETH: [0xfEd52fb1274C053f9728cE269Bf1A7B3f59a74C5](https://optimistic.etherscan.io/address/0xfEd52fb1274C053f9728cE269Bf1A7B3f59a74C5)
- Registry: [0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217](https://optimistic.etherscan.io/address/0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217)

### OP Sepolia

- Implementation Logic: [0x34A860765ED7893d390FE1E3db63f4635effFeC5](https://sepolia-optimism.etherscan.io/address/0x34A860765ED7893d390FE1E3db63f4635effFeC5)
- Implementation Proxy: [0x30Cf371bB8b655a6FabB69B040CCF28Fb7B2A098](https://sepolia-optimism.etherscan.io/address/0x30Cf371bB8b655a6FabB69B040CCF28Fb7B2A098)
- Resolver Logic: [0x64075e0175F1393DDeDa38d0577653872169Ffc0](https://sepolia-optimism.etherscan.io/address/0x64075e0175F1393DDeDa38d0577653872169Ffc0)
- Resolver Proxy: [0x16Af4Cb44e812075e108a95A5A9C7440D15c9B5D](https://sepolia-optimism.etherscan.io/address/0x16Af4Cb44e812075e108a95A5A9C7440D15c9B5D)
- Root: [0x5b2fB670234E52Cb735d759dAe11c9BeF7bEd01e](https://sepolia-optimism.etherscan.io/address/0x5b2fB670234E52Cb735d759dAe11c9BeF7bEd01e)
- ETH: [0xfEd52fb1274C053f9728cE269Bf1A7B3f59a74C5](https://sepolia-optimism.etherscan.io/address/0xfEd52fb1274C053f9728cE269Bf1A7B3f59a74C5)
- Registry: [0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217](https://sepolia-optimism.etherscan.io/address/0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217)

## Deploy on other Superchain

First, create .env file and set the following environment variables:

```
PRIVATE_KEY=0x...
RPC_URL=https://...
CHAIN=...
ETHERSCAN_API_KEY=...
```

Next, run `source .env` to load the environment variables.

And finally, run this command to deploy the contracts:

```bash
source .env
forge script script/DeployDeterministic.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --chain $CHAIN --etherscan-api-key $ETHERSCAN_API_KEY
```

Remove the `--verify` and `--etherscan-api-key` flags if that chain does not support Etherscan. For Blockscout, read https://docs.blockscout.com/devs/verification/foundry-verification

## Configure gateway on ENS mainnet

Unlike other solutions that require you to develop your own gateway on the ETH mainnet, our approach is designed for ease of use: simply set your ENS mainnet resolver to our Superchain Resolver and point it to your SingularResolver deployment with a single transaction.

### 1. Set your ENS mainnet resolver to our Superchain Resolver


### 2. Point your ENS mainnet resolver to your SingularResolver deployment


## Frontend and Backend services deployment

To deploy frontend and backend services, please refer to the README in these repositories:
- https://github.com/Opti-domains/opti-ens-frontend
- https://github.com/Opti-domains/opti-ens-backend

## Customization

Developer can fork this repo and customize the implementation to fit their needs. Here is an overview of each contract:

- `DomainImplementation`: The implementation of the domain contract.
- `DomainRoot`: The root contract of the domain.
- `PermissionedRegistry`: The registry contract that manages domain registration logic.
- `SingularResolver`: The resolver contract that stores and manages domain records.

### SingularResolver

SingularResolver is designed with a concept of one resolver, all superchains. It can be deployed on any Superchain and is instantly compatible with our mainnet Superchain Resolver, eliminating the need to develop your own gateway or CCIP resolver. It supports the following ENS resolver features:
- Text records
- Address records
- Content Hash records

## Commands

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ source .env
$ forge script script/DeployDeterministic.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --chain optimism-sepolia --etherscan-api-key $ETHERSCAN_API_KEY
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
