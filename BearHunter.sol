// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract BearHunter is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public constant burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address public constant bearsToTheMoonAddress = address(0xF1A42B7b96BA15250b05820B44b66DF00791EF25);
    uint256 public constant maxSupply = 10_000_000 * 1e18;
    uint256 public constant bearsToBearHunterRate = 100;

    bool private swapping;
    uint256 public swapTokensAtAmount;
    bool public swapEnabled = false;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    constructor() ERC20("Bear Hunter", "BEARH") {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(address(0xc1f90231035A52091eBCb7dddaCa3051a5F44f30)); // Mainnet UniswapV2Router02 address
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);

        swapTokensAtAmount = totalSupply().div(1000); // 0.1% of total supply
    }

    receive() external payable {}

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function burnBearsToMintBearHunter(uint256 bearsAmount) external {
        require(bearsAmount % bearsToBearHunterRate == 0, "Amount must be a multiple of 100");
        uint256 bearHunterAmount = bearsAmount.div(bearsToBearHunterRate);
        require(totalSupply().add(bearHunterAmount) <= maxSupply, "Exceeds max supply");

        IERC20(bearsToTheMoonAddress).transferFrom(msg.sender, burnAddress, bearsAmount);
        _mint(msg.sender, bearHunterAmount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (swapEnabled && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;

            if (canSwap) {
                swapping = true;
                swapAndLiquify(contractTokenBalance);
                swapping = false;
            }
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 fees = amount.div(100); // 1% fee
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half);
        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, owner(), block.timestamp);
    }

    function enableTrading() external onlyOwner {
        swapEnabled = true;
    }

    // Owner can withdraw any ERC20 tokens mistakenly sent to this contract
    function withdrawERC20(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(owner(), amount);
    }
}
