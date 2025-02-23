## Opti.domains Singular Registry

**A modular and customizable ENS V2-like style recursive registry**

## Deployments

### OP Sepolia

- Implementation Logic: [0x8fD2667c8C9080C295566a5F460ee6873F2101eA](https://sepolia-optimism.etherscan.io/address/0x8fD2667c8C9080C295566a5F460ee6873F2101eA)
- Implementation Proxy: [0xe668886679DB6C1B9a314eD6D353696693ED6176](https://sepolia-optimism.etherscan.io/address/0xe668886679DB6C1B9a314eD6D353696693ED6176)
- Resolver Logic: [0x76d94A0eC4286eeB9DB569CA09ED3AF004289BcB](https://sepolia-optimism.etherscan.io/address/0x76d94A0eC4286eeB9DB569CA09ED3AF004289BcB)
- Resolver Proxy: [0x33b3EB66235CA2eC9A023a24c59C5B4ca8f5F231](https://sepolia-optimism.etherscan.io/address/0x33b3EB66235CA2eC9A023a24c59C5B4ca8f5F231)
- Root: [0x3f39B6ACbE09421587e125B556E045a382aA4550](https://sepolia-optimism.etherscan.io/address/0x3f39B6ACbE09421587e125B556E045a382aA4550)
- ETH: [0xeE7bf06Df559D399E37375D26A290965D8383Eda](https://sepolia-optimism.etherscan.io/address/0xeE7bf06Df559D399E37375D26A290965D8383Eda)
- Registry: [0x8121e862bb196d4a42182e430713b96d78c813bb](https://sepolia-optimism.etherscan.io/address/0x8121e862bb196d4a42182e430713b96d78c813bb)

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
