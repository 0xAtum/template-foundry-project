// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

contract MockERC20 is Test {
  string private constant SIG_BALANCE_OF = "balanceOf(address)";
  string private constant SIG_MINT = "mint(address,uint256)";
  string private constant SIG_BURN = "burn(address,uint256)";
  string private constant SIG_NAME = "name()";
  string private constant SIG_SYMBOL = "symbol()";
  string private constant SIG_DECIMALS = "decimals()";
  string private constant SIG_TOTAL_SUPPLY = "totalSupply()";
  string private constant SIG_ALLOWANCE = "allowance(address,address)";
  string private constant SIG_APPROVE = "approve(address spender, uint256 amount)";
  string private constant SIG_TRANSFER_FROM = "transferFrom(address, address, uint256)";
  string private constant SIG_INCREASE_ALLOWANCE = "increaseAllowance(address, uint256)";
  string private constant SIG_DECREASE_ALLOWANCE = "decreaseAllowance(address, uint256)";

  function mockBalance(address _token, address _of, uint256 _amount) internal {
    vm.mockCall(_token, abi.encodeWithSignature(SIG_BALANCE_OF, _of), abi.encode(_amount));
  }

  function expectMint(address _token, address _of, uint256 _amount) internal {
    vm.expectCall(_token, abi.encodeWithSignature(SIG_MINT, _of, _amount));
  }

  function expectBurn(address _token, address _from, uint256 _amount) internal {
    vm.expectCall(_token, abi.encodeWithSignature(SIG_BURN, _from, _amount));
  }

  function mockName(address _token, string memory _name) internal {
    vm.mockCall(_token, abi.encodeWithSignature(SIG_NAME), abi.encode(_name));
  }

  function mockDecimals(address _token, uint8 _decimals) internal {
    vm.mockCall(_token, abi.encodeWithSignature(SIG_DECIMALS), abi.encode(_decimals));
  }

  function mockTotalSupply(address _token, uint256 _totalSupply) internal {
    vm.mockCall(
      _token, abi.encodeWithSignature(SIG_TOTAL_SUPPLY), abi.encode(_totalSupply)
    );
  }

  function mockAllowance(
    address _token,
    address _of,
    address _spender,
    uint256 _allowance
  ) internal {
    vm.mockCall(
      _token,
      abi.encodeWithSignature(SIG_ALLOWANCE, _of, _spender),
      abi.encode(_allowance)
    );
  }

  function expectApprove(address _token, address _of, uint256 _amount) internal {
    vm.expectCall(_token, abi.encodeWithSignature(SIG_APPROVE, _of, _amount));
  }

  function expectTransfer(address _token, address _to, uint256 _amount) internal {
    vm.expectCall(
      _token, abi.encodeWithSignature("transfer(address,uint256)", _to, _amount)
    );
  }

  function expectTransferFrom(address _token, address _from, address _to, uint256 _amount)
    internal
  {
    vm.expectCall(
      _token,
      abi.encodeWithSignature(
        "transferFrom(address,address,uint256)", _from, _to, _amount
      )
    );
  }
}
