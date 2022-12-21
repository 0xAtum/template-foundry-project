// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../BaseScript.sol";
import { HelloWorld } from "src/HelloWorld.sol";

contract HelloWorldScript is BaseScript {
  struct Config {
    address owner;
  }

  string private constant CONTRACT_NAME = "HelloWorld";

  function run(string memory _network) external {
    string memory file = _getConfig(CONTRACT_NAME);

    Config memory config =
      abi.decode(vm.parseJson(file, string.concat(".", _network)), (Config));

    _loadContracts(_network);

    HelloWorld hello = HelloWorld(contracts[CONTRACT_NAME]);

    vm.startBroadcast(_getDeployer());
    {
      if (address(hello) == address(0)) {
        hello = new HelloWorld(config.owner);
        _saveDeployment(_network, CONTRACT_NAME, address(hello));
      }
    }
    vm.stopBroadcast();
  }
}
