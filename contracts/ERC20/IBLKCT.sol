// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBlockCities is IERC20 {
    function transferPrice(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool);

  function transferPrice_(
        address from,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external returns (uint8);
}