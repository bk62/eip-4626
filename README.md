<!-- <p align="center">
  <a href="https://github.com/pooltogether/pooltogether--brand-assets">
    <img src="https://github.com/pooltogether/pooltogether--brand-assets/blob/977e03604c49c63314450b5d432fe57d34747c66/logo/pooltogether-logo--purple-gradient.png?raw=true" alt="PoolTogether Brand" style="max-width:100%;" width="200">
  </a>
</p>

<br /> -->

# EIP-4626 Implementations

[![Coverage Status](https://coveralls.io/repos/github/bk62/eip-4626/badge.svg?branch=master)](https://coveralls.io/github/bk62/eip-4626?branch=master)

![Tests](https://github.com/bk62/eip-4626/actions/workflows/main.yml/badge.svg)

EIP 4626 implementations.

## IERC4626

An interface for ERC-4626 contracts

## AbstractERC4626

Abstract Contract Implementation of ERC-4626 using OpenZeppelin `ERC20` (including `IERC20Metadat`) and pre/post deposit/withdrawal hooks.

# Development

1. Clone this repo: `git clone git@github.com:bk62/eip-4626.git`
1. Checkout a new branch (`git checkout -b name_of_new_branch`)
1. Begin implementing as appropriate.
1. Compile (`nvm use && yarn compile`)
1. Test (`yarn test`)

# Preset Packages

## Generic Proxy Factory

The minimal proxy factory is a powerful pattern used throughout PoolTogethers smart contracts. A [typescript package](https://www.npmjs.com/package/@pooltogether/pooltogether-proxy-factory-package) is available to use a generic deployed instance. This is typically used in the deployment script.

## Generic Registry

The [generic registry](https://www.npmjs.com/package/@pooltogether/pooltogether-generic-registry) is a iterable singly linked list data structure that is commonly used throughout PoolTogethers contracts. Consider using this where appropriate or deploying in a seperate repo such as the (Prize Pool Registry)[https://github.com/pooltogether/pooltogether-prizepool-registry.

# Installation

Install the repo and dependencies by running:
`yarn`

## Deployment

These contracts can be deployed to a network by running:
`yarn deploy <networkName>`

## Verification

These contracts can be verified on Etherscan, or an Etherscan clone, for example (Polygonscan) by running:
`yarn etherscan-verify <ethereum network name>` or `yarn etherscan-verify-polygon matic`

# Testing

Run the unit tests locally with:
`yarn test`

## Coverage

Generate the test coverage report with:
`yarn coverage`

## References

[EIP 4626](https://eips.ethereum.org/EIPS/eip-4626)
[Solmate ERC4626 Reference Implementation](https://github.com/Rari-Capital/solmate/blob/main/src/test/ERC4626.t.sol)
