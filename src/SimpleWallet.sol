// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract SimpleWallet {
    address payable public owner;
    IERC20 public immutable token;
    uint256 public totalWalletsFunds;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) private allowances;

    // Token will be Sepolia ETH
    constructor(address _token) {
        owner = payable(msg.sender);
        token = IERC20(_token);
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

        token.transferFrom(msg.sender, _to, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, 'Not enough funds in wallet');

        balances[msg.sender] -= _amount;
        totalWalletsFunds -= _amount;

        token.transferFrom(address(this), msg.sender, _amount);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalWalletsFunds() public view returns (uint256) {
        return totalWalletsFunds;
    }
}
