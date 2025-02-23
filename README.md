## Opti.domains Singular Registry

**A modular and customizable ENS V2-like style recursive registry**

## Deployments

### OP Sepolia

- Implementation Logic: [0xa5e4fB359e3650eBDE78EE5b510372a04B943435](https://sepolia-optimism.etherscan.io/address/0xa5e4fB359e3650eBDE78EE5b510372a04B943435)
- Implementation Proxy: [0xc984050B5e3E34cE12b17Ed9e54732498A17c970](https://sepolia-optimism.etherscan.io/address/0xc984050B5e3E34cE12b17Ed9e54732498A17c970)
- Resolver Logic: [0x4F8CA067C66d4117BF7C5Ce493830D08d8004539](https://sepolia-optimism.etherscan.io/address/0x4F8CA067C66d4117BF7C5Ce493830D08d8004539)
- Resolver Proxy: [0xF262CF18a5f0d15C772DE7a36519Ae4D2Fd6CfBB](https://sepolia-optimism.etherscan.io/address/0xF262CF18a5f0d15C772DE7a36519Ae4D2Fd6CfBB)
- Root: [0xcC5f4208E139509aC35088c52b305B9fBB4aEF30](https://sepolia-optimism.etherscan.io/address/0xcC5f4208E139509aC35088c52b305B9fBB4aEF30)
- ETH: [0xb4bdE331Ec292e0542Af66EC31a72d459A87bF49](https://sepolia-optimism.etherscan.io/address/0xb4bdE331Ec292e0542Af66EC31a72d459A87bF49)
- Registry: [0xf9aE710B96f0B058d28D58062deDb5D3a421f4AA](https://sepolia-optimism.etherscan.io/address/0xf9aE710B96f0B058d28D58062deDb5D3a421f4AA)

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
