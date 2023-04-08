// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleWallet {
    address payable public owner;
    IERC20 public immutable token;
    IERC20 public immutable tokenRewards;
    uint256 public totalWalletsFunds;

    mapping(address => uint256) public balances;

    /* Token will be Sepolia ETH
       TokenReward will be a custom token */
    constructor(address _token, address _tokenRewards) {
        owner = payable(msg.sender);
        token = IERC20(_token);
        tokenRewards = IERC20(_tokenRewards);
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, 'Amount must be greater than 0');

        balances[msg.sender] += _amount;
        totalWalletsFunds += _amount;

        token.transferFrom(msg.sender, address(this), _amount);
    }

    function transaction(address _to, uint256 _amount) external {
        require(balances[msg.sender] >= _amount, 'Not enough funds');
        
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, 'Not enough funds in wallet');

        balances[msg.sender] -= _amount;
        totalWalletsFunds -= _amount;

        token.transferFrom(address(this), msg.sender, _amount);
    }

    function stacking() external {

    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalWalletsFunds() public view returns (uint256) {
        return totalWalletsFunds;
    }
}
