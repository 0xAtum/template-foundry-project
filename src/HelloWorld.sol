// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title HelloWorld
 * @author 0xRoxas
 * @notice This is a simple contract to test the deployment script
 * @custom:export abi
 */
contract HelloWorld {
  address public owner;
  uint256 public value;

  modifier onlyOwner() {
    require(owner == msg.sender, "Not Owner");
    _;
  }

  constructor(address _owner) {
    owner = _owner;
  }

  function testMe() external pure returns (uint256) {
    return 99e18;
  }

  function ownerChangeValue(uint256 _newValue) external onlyOwner {
    value = _newValue;
  }
}
