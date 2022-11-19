// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import { LinearVRGDA } from "VRGDAs/LinearVRGDA.sol";
import { NounsToken } from "contracts/NounsToken.sol";
import { INounsSeeder } from "contracts/interfaces/INounsSeeder.sol";
import { INounsDescriptor } from "contracts/interfaces/INounsDescriptor.sol";

import { IWETH } from "contracts/interfaces/IWETH.sol";

import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import { toDaysWadUnsafe } from "solmate/utils/SignedWadMath.sol";

contract LilVRGDA is LinearVRGDA {
    uint256 public nounIdLastSale; // The total number sold
    uint256 public immutable startTime = block.timestamp; // When VRGDA sales begun.

    NounsToken public immutable nouns;
    address public immutable weth;

    constructor(uint256 _nounId, address _nounsTokenAddress, address _weth)
        LinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        )
    {
        nounIdLastSale = _nounId;
        weth = _weth;
        nouns = NounsToken(_nounsTokenAddress);
    }

    function fetchNextNoun() external view returns (string memory svg) {
        // Generate the seed for the next noun.
        INounsSeeder seeder = INounsSeeder(nouns.seeder());
        INounsDescriptor descriptor = INounsDescriptor(nouns.descriptor());
        INounsSeeder.Seed memory nextNounSeed = seeder.generateSeed(
            nounIdLastSale + 1,
            descriptor
        );

        // Generate the SVG from seed using the descriptor.
        svg = descriptor.generateSVGImage(nextNounSeed);

        // TODO also return expected blockhash
        return svg;
    }

    function mint(uint256 invalidAfter) external payable {
        // Check the blockhash is not expired. TODO - use blockhash not deadline.
        require(block.number <= invalidAfter, "Lil Noun expired.");

        // Validate the purchase request against the VRGDA rules.
        uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp - startTime), nounIdLastSale);
        require(msg.value >= price);

        // Call mint on the nouns contract.
        uint mintedNounId = nouns.mint();

        // Sends token to user.
        nouns.transferFrom(address(this), msg.sender, mintedNounId);

        // Sends the funds to the DAO.
        if (msg.value > 0) {
            _safeTransferETHWithFallback(0x4b10701Bfd7BFEdc47d50562b76b436fbB5BdB3B, msg.value); // TODO replace with DAO address or make ownable by DAO
        }

        nounIdLastSale = mintedNounId+1;
        // emit NounPurchased(mintedNounId, msg.sender, msg.value);
    }

    /**
     * @notice Transfer ETH. If the ETH transfer fails, wrap the ETH and try send it as WETH.
     */
    function _safeTransferETHWithFallback(address to, uint256 amount) internal {
        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{ value: amount }();
            IERC20(weth).transfer(to, amount);
        }
    }

    /**
     * @notice Transfer ETH and return the success status.
     * @dev This function only forwards 30,000 gas to the callee.
     */
    function _safeTransferETH(address to, uint256 value) internal returns (bool) {
        (bool success, ) = to.call{ value: value, gas: 30_000 }(new bytes(0));
        return success;
    }
}


