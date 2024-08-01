// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "script/BaseScript.sol";
import { FacetDeployerScript } from "script/utils/diamond/FacetDeployer.sol";

contract MyFacetContract {
//Any Facet Contract
}

contract CustomFacetScript is FacetDeployerScript("ExampleFacet", "IExampleFacet") {
  function tryToDeploy(address _cachedContract) public override returns (address) {
    if (!_isNull(_cachedContract)) return _cachedContract;

    vm.startBroadcast(_getDeployerPrivateKey());
    _cachedContract = address(new MyFacetContract());
    vm.stopBroadcast();

    _saveDeployment(FACET_NAME, _cachedContract);

    return _cachedContract;
  }
}
