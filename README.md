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

## Building custom subdomains registrar on OP Mainnet

Developers can build their own subdomain communities on Optimism by migrating their .eth domains to Optimism and delegating permissions to their custom registrar smart contracts, all without needing to reimplement the gateway.

### 1. Migrate your .eth domains to Optimism

You can migrate your .eth domains to Optimism by using our UI.
* Optimism Mainnet: https://ens.opti.domains
* Optimism Sepolia: https://ens-sepolia.opti.domains

### 2. Develop your custom registrar smart contract

Registrar contract has a `register` function that is called by the UI when a user registers a subdomain. It performs neccessary checks and then calls the `registerSubdomain` function on the domain contract.

```solidity
function register(
    address domain,
    string calldata label,
    address owner,
    ...
) external returns (address) {
    // TODO: Check if user has permission to register a subdomain

    // Register the subdomain
    address subdomain = IDomain(domain).registerSubdomain(label, owner);
    if (subdomain == address(0)) revert RegistrationFailed();

    emit SubdomainRegistered(domain, label, owner, deadline, nonce);

    return subdomain;
}
```

### 3. (Optional) Implement resolver controller logic to the registrar contract

You can implement resolver controller logic to restrict users from setting restricted records to their subdomains. For example, you can restrict users from setting `text` record with only whitelisted keys to their subdomains.

```solidity
function setRecord(
    address domain,
    string calldata key,
    string calldata value,
) external {
    if (isWhitelistedKey(key)) {
        // TODO: Check if user has permission to set this record

        // Set the record
        ISingularResolver(resolver).setText(domain.dnsEncoded(), key, value);
    }
}
```

### 4. Delegate domain permissions to your custom registrar smart contract

Find the address of your domain and call `addAuthorizedDelegate(registrar, true)` on the domain contract.

You can get the address of your domain by calling `getNestedAddress(reverseDnsEncoded)` on the domain root contract.

`reverseDnsEncoded` is the reverse DNS encoded name of your domain. For example, if your domain is `subdomain.mydomain.eth`, `reverseDnsEncoded` is dns encoded name of `eth.mydomain.subdomain`. You can use https://ethtools.com/ethereum-name-service/ens-namehash-labelhash-node-generator to get your domain's reverse DNS encoded name.

(Optional) If you want users to fully control their subdomains, you can call `setSubdomainOwnerDelegation(bool enabled, bool permanent)` on the domain contract. Where `enabled` is `true` and if you want to make it permanent, `permanent` is `true`.

When `setSubdomainOwnerDelegation(true, true)` is called on the parent domain, users are fully owned their subdomains without any control from the parent domain. However, if `setSubdomainOwnerDelegation(true, false)` is called on the parent domain, parent can take the domain back at any time. This is useful in domain renting use cases where users can only control their subdomains for a limited period of time.

### 5. Implement user interface to register subdomains and manage records

Implement a user interface to register subdomains by calling `register` function on your registrar contract and manage records by calling `setRecord` function on your registrar contract. You can fetch existing records by calling respective getter functions on the `SingularResolver` contract.

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

In most cases, you don't need to customize the implementation. You can use our default implementation and just deploy a custom registrar contract and delegate permissions to it.

However, if you insist to customize the implementation, you can fork this repo and customize the implementation to fit their needs. Here is an overview of each contract:

- `DomainImplementation`: The implementation of the domain contract.
- `DomainRoot`: The root contract of the domain.
- `PermissionedRegistry`: The registry contract that manages domain registration logic.
- `SingularResolver`: The resolver contract that stores and manages domain records.

### DomainImplementation

DomainImplementation is the core contract that defines the domain and authorization logic. It is designed to be a modular and customizable ENS V2-like style recursive registry.

You can add more functionalities to every domain name. For example, you can let domain deploy a deterministic contract address given salt. In this case, you can add a `deployContract` function to DomainImplementation.

### DomainRoot

DomainRoot is the contract that manages root node in the domain name system. It's usually owned by a multisig wallet with Timelock.

Root node is the parent of top-level domains such as .eth, .crypto, .nft, etc. These are all subdomains of the root node.

### PermissionedRegistry

PermissionedRegistry is the contract that manages domain registration logic. Please read "Develop and deploy your custom registrar smart contract" section above for more details.

### SingularResolver

SingularResolver is designed with a concept of one resolver, all superchains. It can be deployed on any Superchain and is instantly compatible with our mainnet Superchain Resolver, eliminating the need to develop your own gateway or CCIP resolver. It supports the following ENS resolver features:
- Text records
- Address records
- Content Hash records

You are free to customize the resolver to add support for more types of records.

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
