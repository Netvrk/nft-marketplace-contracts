pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { AddressUpgradeable as Address } from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

abstract contract RoyaltyBase is OwnableUpgradeable {
  using Address for address;

  mapping(uint256 => address) public creators;
  uint256 public royaltyPercentageForCreator; // 100 for 1%
  uint256 public royaltyPercentageForAdmin;

  struct RoyaltyDistribution {
    address payable receiver;
    uint256 percentage;
  }

  mapping(uint256 => RoyaltyDistribution[]) public royaltyDistributions;

  modifier validDistributions(RoyaltyDistribution[] memory _distributions) {
    uint256 totalPercentage = 0;
    for(uint256 i = 0; i < _distributions.length; i ++) {
      address receiver = _distributions[i].receiver;
      require(receiver != address(0), "Invalid payout address");
      require(receiver.isContract() == false, "Contract address is not eligible for royalty");
      totalPercentage += _distributions[i].percentage;
    }
    require(totalPercentage <= 10000, "Royalty fee overflow");

    _;
  }

  modifier onlyOwnerOrCreator(uint256 tokenId) {
    require(msg.sender == owner() || msg.sender == creators[tokenId], "Not owner nor creator");
    _;
  }

  function setRoyaltyPercentageForCreator(uint256 _royaltyPercentageForCreator) external virtual onlyOwner {
    royaltyPercentageForCreator = _royaltyPercentageForCreator;
  }

  function setRoyaltyPercentageForAdmin(uint256 _royaltyPercentageForAdmin) external virtual onlyOwner {
    royaltyPercentageForAdmin = _royaltyPercentageForAdmin;
  }

  function setCreatorForToken(address creator, uint256 tokenId) external virtual onlyOwnerOrCreator(tokenId) {
    require(creator != address(0), "Invalid creator address");
    creators[tokenId] = creator;
  }

  function setRoyaltyInfo(uint256 tokenId, RoyaltyDistribution[] memory _distributions) external virtual
    onlyOwnerOrCreator(tokenId)
    validDistributions(_distributions)
  {
    delete royaltyDistributions[tokenId];
    for (uint256 i = 0; i < _distributions.length; i++) {
      RoyaltyDistribution memory d = _distributions[i];
      royaltyDistributions[tokenId].push(d);
    }
  }

  /**
   * @notice Do not use this function in production
   * @dev This function is just for EIP-2981 standard
   */
  function royaltyInfo(uint256 tokenId, uint256 salePrice) external view virtual returns (address receiver, uint256 royaltyAmount) {
    receiver = creators[tokenId];
    royaltyAmount = (salePrice * royaltyPercentageForCreator) / 10000;
  }

  /**
   * @notice Do not use this function in production
   */
  function royaltyInfoAdmin(uint256 salePrice) external view virtual returns (address receiver, uint256 royaltyAmount);

  /**
   * @notice Do not use this function in production
   */
  function totalRoyaltyFee(uint256 salePrice) external view virtual returns (uint256 royaltyFee) {
    royaltyFee = (salePrice * (royaltyPercentageForCreator + royaltyPercentageForAdmin)) / 10000;
  }

  event RoyaltyFeePaid(address indexed _receiver, uint256 _amount);
  event RoyaltyFeePaidForAdmin(address indexed _receiver, uint256 _amount);
}
