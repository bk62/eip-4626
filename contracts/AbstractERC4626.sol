// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IERC4626.sol";

/**
 * @title EIP 4626 specification
 * @notice Implementation of EIP 4626
 * as defined in https://eips.ethereum.org/EIPS/eip-4626
 * @dev Implements pre-deposit, post-deposit, pre-withdrawal and post-withdrawal hooks.
 * {totalAssets}, {convertToShares}, {convertToAssets}, {previewMint} and {previewWithdraw} methods are abstract and
 * need to be overridden by a concrete implementation.
 */
abstract contract AbstractERC4626 is IERC4626, ERC20 {
  using SafeERC20 for IERC20Metadata;

  // Note: The spec requires that the underlying token implements the metadata extensions to ERC-20
  IERC20Metadata public immutable asset_;

  /**
   * @notice Constructor
   * @param _asset Underlying ERC20 token, must implement OpenZeppelin's `IERC20Metadata` extension to ERC-20
   * @param _name Name of vault share token
   * @param _symbol Symbol of vault share token
   */
  constructor(
    IERC20Metadata _asset,
    string memory _name,
    string memory _symbol
  ) ERC20(_name, _symbol) {
    asset_ = _asset;
  }

  /**
   * @notice Returns the number of decimals used
   * @dev Unless overridden, same as the number of decimals used by the underlying token.
   */
  function decimals() public view virtual override returns (uint8) {
    return asset_.decimals();
  }

  /**
   * @notice See {IERC4626-asset}
   */
  function asset() public view virtual override returns (address assetTokenAddress) {
    assetTokenAddress = address(asset_);
  }

  /**
   * @notice See {IERC4626-totalAssets}
   * @dev Unless overridden, returns vault's total balance of the underlying token.
   */
  function totalAssets() public view virtual override returns (uint256 totalManagedAssets) {
    totalManagedAssets = asset_.balanceOf(address(this));
  }

  /**
   * @notice See {IERC4626-convertToShares}
   * @dev Abstract method
   */
  function convertToShares(uint256 assets) public view virtual override returns (uint256 shares);

  /**
   * @notice See {IERC4626-convertToAssets}
   * @dev Abstract method
   */
  function convertToAssets(uint256 shares) public view virtual override returns (uint256 assets);

  /**
   * @notice See {IERC4626-maxDeposit}
   * @dev Unless overridden, returns `type(uint256).max`
   */
  function maxDeposit(address) public view virtual override returns (uint256 maxAssets) {
    return type(uint256).max;
  }

  /**
   * @notice See {IERC4626-previewDeposit}
   * @dev Unless overridden,, returns result of {convertToShares}
   */
  function previewDeposit(uint256 assets) public view virtual override returns (uint256 shares) {
    shares = convertToShares(assets);
  }

  /**
   * @notice See {IERC4626-deposit}
   * @dev Calls hooks {_beforeDeposit} and {_afterDeposit} before and after depositing respectively.
   */
  function deposit(uint256 assets, address receiver)
    public
    virtual
    override
    returns (uint256 shares)
  {
    // Check for rounding error
    require((shares = previewDeposit(assets)) != 0, "EIP4626: zero shares");

    _beforeDeposit(assets, shares);

    asset_.safeTransferFrom(msg.sender, address(this), assets);
    _mint(receiver, shares);

    emit Deposit(msg.sender, receiver, assets, shares);

    _afterDeposit(assets, shares);
  }

  /**
   * @notice See {IERC4626-maxMint}
   * @dev Unless overridden,, returns `type(uint256).max`
   */
  function maxMint(address) public view virtual override returns (uint256 maxShares) {
    return type(uint256).max;
  }

  /**
   * @notice See {IERC4626-previewMint}
   * @dev Abstract method
   */
  function previewMint(uint256 shares) public view virtual override returns (uint256 assets);

  /**
   * @notice See {IERC4626-mint}
   * @dev  Calls hooks {_beforeDeposit} and {_afterDeposit} before and after minting respectively.
   */
  function mint(uint256 shares, address receiver) public virtual override returns (uint256 assets) {
    // no need to check for rounding errors b/c rounding up in previewMint
    assets = previewMint(shares);

    _beforeDeposit(assets, shares);

    asset_.safeTransferFrom(msg.sender, address(this), assets);
    _mint(receiver, shares);

    emit Deposit(msg.sender, receiver, assets, shares);

    _afterDeposit(assets, shares);
  }

  /**
   * @notice See {IERC4626-maxWithdraw}
   * @dev Unless overridden, returns result of {convertToAssets} when passed the `owner` share balance
   */
  function maxWithdraw(address owner) public view virtual override returns (uint256 maxAssets) {
    maxAssets = convertToAssets(balanceOf(owner));
  }

  /**
   * @notice See {IERC4626-previewWithdraw}
   * @dev Abstract method
   */
  function previewWithdraw(uint256 assets) public view virtual override returns (uint256 shares);

  /**
   * @notice See {IERC4626-withdraw}
   * @dev Calls hooks {_beforeWithdrawal} and {_afterWithdrawal} before and after withdrawing respectively.
   */
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) public virtual override returns (uint256 shares) {
    // rounded up so not checking for rounding errors
    shares = previewWithdraw(assets);

    if (msg.sender != owner) {
      decreaseAllowance(msg.sender, shares);
    }

    _beforeWithdrawal(assets, shares);

    _burn(owner, shares);
    asset_.safeTransfer(receiver, assets);

    emit Withdraw(msg.sender, receiver, owner, assets, shares);

    _afterWithdrawal(assets, shares);
  }

  /**
   * @notice See {IERC4626-maxRedeem}
   * @dev Unless overridden, returns `owner` share balance
   */
  function maxRedeem(address owner) public view virtual override returns (uint256 maxShares) {
    maxShares = balanceOf(owner);
  }

  /**
   * @notice See {IERC4626-previewRedeem}
   * @dev Unless overridden, returns result of {convertToAssets}
   */
  function previewRedeem(uint256 shares) public view virtual override returns (uint256 assets) {
    assets = convertToAssets(shares);
  }

  /**
   * @notice See {IERC4626-redeem}
   * @dev Calls hooks {_beforeWithdrawal} and {_afterWithdrawal} before and after withdrawing respectively.
   */
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) public virtual override returns (uint256 assets) {
    if (msg.sender != owner) {
      decreaseAllowance(msg.sender, shares);
    }

    require((assets = previewRedeem(shares)) != 0, "EIP4626: zero assets");

    _beforeWithdrawal(assets, shares);

    _burn(owner, shares);
    asset_.safeTransfer(receiver, assets);

    emit Withdraw(msg.sender, receiver, owner, assets, shares);

    _afterWithdrawal(assets, shares);
  }

  // Hooks

  /**
   * @notice Before withdrawal hook
   * @dev Hook that is called before any withdrawals -- including withdrawing and redeeming
   */
  function _beforeWithdrawal(uint256 assets, uint256 shares) internal virtual {}

  function _afterWithdrawal(uint256 assets, uint256 shares) internal virtual {}

  function _beforeDeposit(uint256 assets, uint256 shares) internal virtual {}

  function _afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
