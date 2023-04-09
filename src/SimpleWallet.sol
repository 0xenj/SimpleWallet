// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleWallet {
    address public owner;
    IERC20 public immutable token;
    IERC20 public immutable tokenRewards;
    uint256 public totalWalletsFunds;
    uint256 public totalStaking;
    // time funds are lock to stake
    uint32 public duration;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public stake;
    mapping(address => uint256) public stakeLock;

    /* Token will be Sepolia ETH
       TokenReward will be a custom token */
    constructor(address _token, address _tokenRewards, uint32 _duration) {
        owner = msg.sender;
        token = IERC20(_token);
        tokenRewards = IERC20(_tokenRewards);
        duration = _duration;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
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

    function stacking(uint256 _amount) external {
        require(_amount > 0, 'amount = 0');
        require(balances[msg.sender] >= _amount, 'Not enough funds on wallet');

        balances[msg.sender] -= _amount;
        stake[msg.sender] += _amount;
        stakeLock[msg.sender] += block.timestamp + duration;
        totalStaking += _amount;

    }

    function unStaking() external {}

    function setDuration(uint32 _duration) external onlyOwner {
        duration = _duration;
    }

    function getDuration() public view returns (uint32) {
        return duration;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getStaking() public view returns (uint256) {
        return stake[msg.sender];
    }

    function getTotalStaking() public view returns (uint256) {
        return totalStaking;
    }

    function getTotalWalletsFunds() public view returns (uint256) {
        return totalWalletsFunds;
    }
}
