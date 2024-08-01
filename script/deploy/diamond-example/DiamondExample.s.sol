// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "script/BaseScript.sol";
import { DiamondHelper } from "script/utils/diamond/DiamondHelper.sol";
import { IDiamondCut } from "script/utils/diamond/IDiamondCut.sol";
import { CustomFacetScript } from "./CustomFacet.s.sol";

import { ExampleDiamondApp } from "src/ExampleDiamondApp.sol";
import { DiamondCutFacet } from "src/diamond/facets/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "src/diamond/facets/DiamondLoupeFacet.sol";

/**
 * @title DiamondExample
 * @notice The whole idea of DiamondHelper is it uses your interface to fulfill
 * IDiamondCut.FacetCut automatically. If you do not have all your functions in
 * your interface, it will not work.
 */
contract DiamondExample is BaseScript, DiamondHelper {
  string private constant DIAMOND_CUT = "DiamondCutFacet";
  string private constant DIAMOND_CUT_INTERFACE = "IDiamondCut";
  string private constant DIAMOND_LOUPE = "DiamondLoupeFacet";
  string private constant DIAMOND_LOUPE_INTERFACE = "IDiamondLoupe";

  function run() external {
    _loadContracts();
    IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](0);

    //Deploy Implementation of Core Diamond Proxy (DiamondCutFacet & DiamondLoupeFacet)
    _deployCoreFacetOfDiamondProxy();

    //Add Core Diamond Proxy
    facetCuts = _concatFacetCuts(facetCuts, _getFacetCutCoreDiamondProxy());

    //Deploy Implementation of "MyFacetContract"
    // myCustonFacet.tryToDeploy();

    //Add Facet Cut of MyFacetContract
    // facetCuts = _concatFacetCuts(facetCuts, myCustonFacet.getFacetCuts());

    (address a,) = _tryDeployContract(
      "DiamondExampleContract",
      0,
      type(ExampleDiamondApp).creationCode,
      abi.encode(facetCuts)
    );
  }

  function _deployCoreFacetOfDiamondProxy()
    internal
    returns (address diamondCut_, address diamondLoupe_, address ownership_)
  {
    diamondCut_ = contracts[DIAMOND_CUT];
    diamondLoupe_ = contracts[DIAMOND_LOUPE];

    if (_isNull(diamondCut_)) {
      vm.broadcast(_getDeployerPrivateKey());
      diamondCut_ = address(new DiamondCutFacet());

      _saveDeployment(DIAMOND_CUT, diamondCut_);
    }

    if (_isNull(diamondLoupe_)) {
      vm.broadcast(_getDeployerPrivateKey());
      diamondLoupe_ = address(new DiamondLoupeFacet());

      _saveDeployment(DIAMOND_LOUPE, diamondLoupe_);
    }

    return (diamondCut_, diamondLoupe_, ownership_);
  }

  function _getFacetCutCoreDiamondProxy()
    internal
    view
    returns (IDiamondCut.FacetCut[] memory)
  {
    address diamondCut = contracts[DIAMOND_CUT];
    address diamondLoupe = contracts[DIAMOND_LOUPE];

    require(!_isNull(diamondCut) && !_isNull(diamondLoupe), "Facet not deployed.");

    address[] memory interfaces = new address[](2);
    interfaces[0] = diamondCut;
    interfaces[1] = diamondLoupe;

    string[] memory interfaceNames = new string[](2);
    interfaceNames[0] = DIAMOND_CUT_INTERFACE;
    interfaceNames[1] = DIAMOND_LOUPE_INTERFACE;

    return _generateAllCuts(interfaceNames, interfaces);
  }
}
