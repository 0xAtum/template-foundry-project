// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import { strings } from "./utils/strings.sol";

contract BaseScript is Script {
  using strings for string;
  using strings for strings.slice;

  struct Deployment {
    address contractAddress;
    string contractName;
  }

  string private constant PATH_CONFIG = "/script/config/";
  string private constant ENV_PRIVATE_KEY = "DEPLOYER_PRIVATE_KEY";
  string private constant ENV_DEPLOY_NETWORK = "DEPLOY_NETWORK";
  string private constant DEPLOY_HISTORY_PATH = "/deployment/";
  string private constant KEY_CONTRACT_NAME = "contractName";

  mapping(string => address) internal contracts;

  /**
   * @notice _setNetwork define env value of DEPLOY_NETWORK
   * @dev it should be the first function called inside run(string memory _network)
   */
  function _setNetwork(string memory _network) internal {
    vm.setEnv(ENV_DEPLOY_NETWORK, _network);
  }

  /**
   * @notice _getNetwork return the .env variable DEPLOY_NETWORK.
   * @dev For a better experience, DEPLOY_NETWORK should be defined via _setNetwork(string memory _network) and not .env
   */
  function _getNetwork() internal view returns (string memory) {
    return vm.envString(ENV_DEPLOY_NETWORK);
  }

  /**
   * @notice _saveDeployment - Get config file from "/script/config/`_fileName`.json
   * @param _contractName the name of the contract (what will be shown inside the /deployments/ file)
   * @param _contractAddress the address of the contract
   * @dev If the `_contractName` already exists, it will not save it again
   * @dev Simulation broadcast will also save inside the deployments file. I haven't find a way to detect simulations yet
   */
  function _saveDeployment(string memory _contractName, address _contractAddress)
    internal
  {
    vm.label(_contractAddress, _contractName);
    if (vm.envBool("IS_SIMULATION")) return;

    string memory json = "NewDeployment";
    string memory insertData;

    vm.serializeString(json, "contractName", _contractName);
    string memory output = vm.serializeAddress(json, "contractAddress", _contractAddress);

    string memory currentData = vm.readFile(_getDeploymentPath(_getNetwork()));
    strings.slice memory slicedCurrentData = currentData.toSlice();

    if (
      slicedCurrentData.contains(_contractName.toSlice())
        || slicedCurrentData.contains(string(abi.encodePacked(_contractAddress)).toSlice())
    ) {
      console.log(_contractName, "Already exists");
      return;
    }

    if (slicedCurrentData.contains(KEY_CONTRACT_NAME.toSlice())) {
      insertData = _addContractToString(currentData, output);
    } else {
      insertData = string.concat("[", output);
      insertData = string.concat(insertData, "]");
    }

    vm.writeJson(insertData, _getDeploymentPath(_getNetwork()));
  }

  function _addContractToString(string memory _currentData, string memory _contractData)
    private
    pure
    returns (string memory modifiedData_)
  {
    string memory f = "}";

    strings.slice memory sliceDatas = _currentData.toSlice();
    strings.slice memory needle = f.toSlice();

    modifiedData_ = sliceDatas.copy().rfind(needle).toString();

    modifiedData_ = string.concat(modifiedData_, ",");
    modifiedData_ = string.concat(modifiedData_, _contractData);
    modifiedData_ = string.concat(modifiedData_, "]");

    return modifiedData_;
  }

  /**
   * @notice _getConfig - Get config file from "/script/config/`_fileName`.json
   * @param _fileName the name of the config file (without extension)
   * @return fileData_ Raw data of the file. use vm.parseJson(fileData_, jsonKey) to get the json encoded data
   */
  function _getConfig(string memory _fileName) internal view returns (string memory) {
    string memory inputDir = string.concat(vm.projectRoot(), PATH_CONFIG);
    string memory file = string.concat(_fileName, ".json");
    return vm.readFile(string.concat(inputDir, file));
  }

  /**
   * @notice _getDeployer - Get the deployer with the private key inside .env
   * @return deployerAddress the deployer address in uint256 format
   */
  function _getDeployer() internal view returns (uint256) {
    return vm.envUint(ENV_PRIVATE_KEY);
  }

  /**
   * @notice _loadContracts - Loads the deployed contracts from a network inside the mapping "contracts"
   */
  function _loadContracts() internal {
    Deployment[] memory deployments = _getDeployedContracts(_getNetwork());

    Deployment memory cached;
    uint256 length = deployments.length;
    for (uint256 i = 0; i < length; ++i) {
      cached = deployments[i];
      contracts[cached.contractName] = cached.contractAddress;
      vm.label(cached.contractAddress, cached.contractName);
    }
  }

  /**
   * @notice _getDeployedContracts - Gets the deployed contracts from a specific network
   * @param _network the name of the network
   * @return deployments_ Array of Deployment[] Structure
   */
  function _getDeployedContracts(string memory _network)
    internal
    view
    returns (Deployment[] memory deployments_)
  {
    bytes memory json = _getDeployedContractsJson(_network);

    if (keccak256(json) == keccak256("")) return deployments_;

    return abi.decode(json, (Deployment[]));
  }

  /**
   * @notice _getDeployedContractsJson - Gets the Encoded Json of the deployment file
   * @param _network the name of the network
   * @return jsonBytes_ Encoded version of the json
   */
  function _getDeployedContractsJson(string memory _network)
    private
    view
    returns (bytes memory jsonBytes_)
  {
    string memory fileData = vm.readFile(_getDeploymentPath(_network));

    if (fileData.toSlice().empty()) return jsonBytes_;

    return vm.parseJson(fileData);
  }

  function _getDeploymentPath(string memory _network)
    private
    view
    returns (string memory)
  {
    string memory root = vm.projectRoot();
    string memory path = string.concat(root, DEPLOY_HISTORY_PATH);
    string memory file = string.concat(_network, ".json");

    return string.concat(path, file);
  }

  function _isNull(address _a) internal pure returns (bool) {
    return _a == address(0);
  }
}
