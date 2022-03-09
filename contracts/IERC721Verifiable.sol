// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC721Upgradeable as IERC721} "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";


interface IERC721Verifiable is IERC721 {
  function verifyFingerprint(uint256, bytes memory) external view returns (bool);
}