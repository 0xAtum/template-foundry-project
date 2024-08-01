// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { LibDiamond } from "./diamond/libraries/LibDiamond.sol";
import { IDiamondLoupe } from "./diamond/interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "./diamond/interfaces/IDiamondCut.sol";
import { IERC165 } from "./diamond/interfaces/IERC165.sol";

contract ExampleDiamondApp {
  error FunctionNotFound();

  constructor(IDiamondCut.FacetCut[] memory _diamondCut) {
    LibDiamond.diamondCut(_diamondCut, address(0), "");
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
    ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
  }

  receive() external payable { }

  fallback() external payable {
    LibDiamond.DiamondStorage storage ds;
    bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
    assembly {
      ds.slot := position
    }

    address facet = address(bytes20(ds.facets[msg.sig]));
    if (facet == address(0)) revert FunctionNotFound();

    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }
}
