// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../BaseScript.sol";
import { HelloWorld } from "src/HelloWorld.sol";

/**
 * @dev IMPORTANT: When performing cross-chain deployments, ensure that you do not
 * store the results of _getDeployerAddress() or _getDeployerPrivateKey() locally
 * unless you have called _changeNetwork() beforehand. Failing to do so will result
 * in using the LocalHost's private key.
 */
contract CrossChainDeployExampleScript is BaseScript {
  struct Config {
    address owner;
    uint256 exampleInt;
    string exampleString;
    address ownerTwo;
  }

  string private constant CONTRACT_NAME = "HelloWorld";
  string[] private MULTI_CHAINS = ["sonicTestnet", "sepolia"];

  function run() external override {
    string memory file = _getConfig(CONTRACT_NAME);

    for (uint256 i = 0; i < MULTI_CHAINS.length; ++i) {
      _deployToChain(file, MULTI_CHAINS[i]);
    }

    for (uint256 i = 0; i < MULTI_CHAINS.length; ++i) {
      console.log(
        "Address on ",
        MULTI_CHAINS[i],
        _tryGetContractAddress(MULTI_CHAINS[i], CONTRACT_NAME)
      );
    }
  }

  function _deployToChain(string memory file, string memory chainName) internal {
    _changeNetwork(chainName);

    // Load contracts in simulation
    // _loadDeployedContractsInSimulation();

    Config memory config =
      abi.decode(vm.parseJson(file, string.concat(".", _getNetwork())), (Config));

    // Asserts are there as an example to showcase the config is functionnal
    assert(
      keccak256(abi.encode(config.exampleString)) == keccak256(abi.encode("HelloWorld"))
    );
    assert(config.exampleInt == 102);
    assert(config.owner == address(0xADaE1798F761Fa7fce29B6673D453d1a48A2931A));
    assert(config.ownerTwo == address(0x912CE59144191C1204E64559FE8253a0e49E6548));

    (address helloWorldAddress,) = _tryDeployContract(
      CONTRACT_NAME, 0, type(HelloWorld).creationCode, abi.encode(config.owner)
    );

    HelloWorld hello = HelloWorld(helloWorldAddress);
    console.log(hello.testMe());

    console.log("Deployed to", _getNetwork());
  }
}
