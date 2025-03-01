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

## Usage

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
