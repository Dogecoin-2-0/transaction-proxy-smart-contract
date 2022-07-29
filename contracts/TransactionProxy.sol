pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import './helpers/TransferHelpers.sol';

contract TransactionProxy is Ownable, AccessControl {

  using SafeMath for uint256;

  bytes32 public withdrawerRole = keccak256(abi.encode('WITHDRAWER_ROLE'));
  uint256 public immutable deployTime;

  constructor() {
    _grantRole(withdrawerRole, _msgSender());
    deployTime = block.timestamp;
  }

  function calculateFee(uint256 amount) private view returns (uint256 fee) {
    uint256 ratio = deployTime / block.timestamp;
    fee = ratio * amount;
  }

  function proxyTransferEther(address to) external payable {
    uint256 fee = calculateFee(msg.value);
    uint256 amount = msg.value.sub(fee);
    TransferHelpers._safeTransferEther(to, amount);
  }
}
