// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract FixedRateSwapPro is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    IERC20 public immutable tokenIn;
    IERC20 public immutable tokenOut;
    
    address public treasury;
    uint256 public exchangeRate;
    uint256 public feeBasisPoints; 
    uint256 public constant MAX_FEE_BPS = 1000; 

    error ZeroAddress();
    error InvalidAmount();
    error InvalidRate();
    error InvalidFee();
    error InsufficientLiquidity(uint256 requested, uint256 available);

    event SwapExecuted(address indexed user, uint256 amountIn, uint256 amountOut, uint256 feeAmount);
    event RateUpdated(uint256 newRate);
    event FeeUpdated(uint256 newFeeBps);
    event TreasuryUpdated(address newTreasury);
    event LiquidityWithdrawn(address indexed token, uint256 amount, address to);

    constructor(
        address _tokenIn,
        address _tokenOut,
        uint256 _initialRate,
        uint256 _feeBps,
        address _treasury
    ) {
        if (_tokenIn == address(0) || _tokenOut == address(0) || _treasury == address(0)) revert ZeroAddress();
        if (_initialRate == 0) revert InvalidRate();
        if (_feeBps > MAX_FEE_BPS) revert InvalidFee();

        tokenIn = IERC20(_tokenIn);
        tokenOut = IERC20(_tokenOut);
        exchangeRate = _initialRate;
        feeBasisPoints = _feeBps;
        treasury = _treasury;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);
    }

    function swap(uint256 amountIn) external nonReentrant whenNotPaused {
        if (amountIn == 0) revert InvalidAmount();

        uint256 feeAmount = (amountIn * feeBasisPoints) / 10000;
        uint256 amountAfterFee = amountIn - feeAmount;
        uint256 amountOut = amountAfterFee * exchangeRate;

        uint256 contractBalance = tokenOut.balanceOf(address(this));
        if (contractBalance < amountOut) revert InsufficientLiquidity(amountOut, contractBalance);

        if (feeAmount > 0) {
            tokenIn.safeTransferFrom(msg.sender, treasury, feeAmount);
        }

        tokenIn.safeTransferFrom(msg.sender, address(this), amountAfterFee);
        tokenOut.safeTransfer(msg.sender, amountOut);

        emit SwapExecuted(msg.sender, amountIn, amountOut, feeAmount);
    }

    function setExchangeRate(uint256 newRate) external onlyRole(MANAGER_ROLE) {
        if (newRate == 0) revert InvalidRate();
        exchangeRate = newRate;
        emit RateUpdated(newRate);
    }

    function setFeeBasisPoints(uint256 newFeeBps) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newFeeBps > MAX_FEE_BPS) revert InvalidFee();
        feeBasisPoints = newFeeBps;
        emit FeeUpdated(newFeeBps);
    }

    function setTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (newTreasury == address(0)) revert ZeroAddress();
        treasury = newTreasury;
        emit TreasuryUpdated(newTreasury);
    }

    function pause() external onlyRole(MANAGER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(MANAGER_ROLE) {
        _unpause();
    }

    function withdrawLiquidity(address token, uint256 amount, address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(to, amount);
        emit LiquidityWithdrawn(token, amount, to);
    }
}
