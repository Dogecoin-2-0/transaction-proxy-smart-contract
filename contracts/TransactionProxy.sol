pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./helpers/TransferHelpers.sol";

contract TransactionProxy is Ownable, AccessControl {
  using SafeMath for uint256;

  bytes32 public withdrawerRole = keccak256(abi.encode("WITHDRAWER_ROLE"));
  uint256 public immutable deployTime;

  constructor() {
    _grantRole(withdrawerRole, _msgSender());
    deployTime = block.timestamp;
  }

  function calculateFee(uint256 amount) private view returns (uint256 fee) {
    uint256 ratio = deployTime.mul(10).div(block.timestamp);
    fee = ratio.mul(amount).div(10);
  }

  function proxyTransferEther(address to) external payable {
    uint256 fee = calculateFee(msg.value);
    uint256 amount = msg.value.sub(fee);
    TransferHelpers._safeTransferEther(to, amount);
  }

  function proxyTransferERC20(
    address token,
    address recipient,
    uint256 amount
  ) external {
    require(IERC20(token).allowance(_msgSender(), address(this)) >= amount, "no_allowance");
    uint256 fee = calculateFee(amount);
    uint256 val = amount.sub(fee);
    TransferHelpers._safeTransferFromERC20(token, _msgSender(), recipient, val);
    TransferHelpers._safeTransferFromERC20(token, _msgSender(), address(this), fee);
  }

  function withdrawEther(address to) external {
    require(hasRole(withdrawerRole, _msgSender()), "only_withdrawer");
    TransferHelpers._safeTransferEther(to, address(this).balance);
  }

  function withdrawToken(address token, address to) external {
    require(hasRole(withdrawerRole, _msgSender()), "only_withdrawer");
    TransferHelpers._safeTransferERC20(token, to, IERC20(token).balanceOf(address(this)));
  }

  function setWithdrawer(address withdrawer) external onlyOwner {
    require(!hasRole(withdrawerRole, withdrawer), "already_withdrawer");
    _grantRole(withdrawerRole, withdrawer);
  }

  function removeWithdrawer(address withdrawer) external onlyOwner {
    require(hasRole(withdrawerRole, withdrawer), "not_yet_withdrawer");
    _revokeRole(withdrawerRole, withdrawer);
  }
}
