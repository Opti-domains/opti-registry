## Opti.domains Singular Registry

**A modular and customizable ENS V2-like style recursive registry**

## Deployments

### OP Sepolia

* Implementation: [0xE5Db2Dc984c5A80631439DE510E278f39dC11B97](https://sepolia-optimism.etherscan.io/address/0xE5Db2Dc984c5A80631439DE510E278f39dC11B97)
* Resolver: [0x5d3C7E7a787f6ca841437BB59504f0C5d073b2c5](https://sepolia-optimism.etherscan.io/address/0x5d3C7E7a787f6ca841437BB59504f0C5d073b2c5)
* Root: [0x57348b15057cC6FeAe36Cd0Fc2018618809B4c5F](https://sepolia-optimism.etherscan.io/address/0x57348b15057cC6FeAe36Cd0Fc2018618809B4c5F)
* Registry: [0x0793454a408c13bD6623c045dc7024EC9680b8C3](https://sepolia-optimism.etherscan.io/address/0x0793454a408c13bD6623c045dc7024EC9680b8C3)

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
$ forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --chain optimism-sepolia --etherscan-api-key $ETHERSCAN_API_KEY
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
