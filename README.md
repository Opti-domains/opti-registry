## Opti.domains Singular Registry

**A modular and customizable ENS V2-like style recursive registry**

## Deployments

### OP Mainnet

- Implementation Logic: [0x6de96571556a1306833f980138A63aC57Df7A349](https://optimistic.etherscan.io/address/0x6de96571556a1306833f980138A63aC57Df7A349)
- Implementation Proxy: [0xaC95E0745B686EE0a2Ed1aD8307B514aA2E0D893](https://optimistic.etherscan.io/address/0xaC95E0745B686EE0a2Ed1aD8307B514aA2E0D893)
- Resolver Logic: [0x10264C1cC407f2196F0db753415D9fc255C298a8](https://optimistic.etherscan.io/address/0x10264C1cC407f2196F0db753415D9fc255C298a8)
- Resolver Proxy: [0xF486bfD0fE7c136231052bC9DD7C4f57870c8Ef1](https://optimistic.etherscan.io/address/0xF486bfD0fE7c136231052bC9DD7C4f57870c8Ef1)
- Root: [0x6E3fF3d77d4cb7Ae4b2f4c5112240596E37526da](https://optimistic.etherscan.io/address/0x6E3fF3d77d4cb7Ae4b2f4c5112240596E37526da)
- ETH: [0xb2A0DE957B080d238E319845FBceAaAc726979c3](https://optimistic.etherscan.io/address/0xb2A0DE957B080d238E319845FBceAaAc726979c3)
- Registry: [0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217](https://optimistic.etherscan.io/address/0x02fB1fEb8cBf1E35c55e6b930452E011d5FB6217)

### OP Sepolia

- Implementation Logic: [0x6de96571556a1306833f980138A63aC57Df7A349](https://sepolia-optimism.etherscan.io/address/0x6de96571556a1306833f980138A63aC57Df7A349)
- Implementation Proxy: [0xaC95E0745B686EE0a2Ed1aD8307B514aA2E0D893](https://sepolia-optimism.etherscan.io/address/0xaC95E0745B686EE0a2Ed1aD8307B514aA2E0D893)
- Resolver Logic: [0x10264C1cC407f2196F0db753415D9fc255C298a8](https://sepolia-optimism.etherscan.io/address/0x10264C1cC407f2196F0db753415D9fc255C298a8)
- Resolver Proxy: [0xF486bfD0fE7c136231052bC9DD7C4f57870c8Ef1](https://sepolia-optimism.etherscan.io/address/0xF486bfD0fE7c136231052bC9DD7C4f57870c8Ef1)
- Root: [0x6E3fF3d77d4cb7Ae4b2f4c5112240596E37526da](https://sepolia-optimism.etherscan.io/address/0x6E3fF3d77d4cb7Ae4b2f4c5112240596E37526da)
- ETH: [0xb2A0DE957B080d238E319845FBceAaAc726979c3](https://sepolia-optimism.etherscan.io/address/0xb2A0DE957B080d238E319845FBceAaAc726979c3)
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
