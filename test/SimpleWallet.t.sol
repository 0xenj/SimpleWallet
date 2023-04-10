// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SimpleWallet.sol";
import "./MockERC20.sol";

contract SimpleWalletTest is Test {
    SimpleWallet public simplewallet;
    MockERC20 public token;
    MockERC20 public tokenRewards;
    address owner;
    uint256 totalSupplytokenRewards;

    function setUp() public {
        owner = vm.addr(1);
        token = new MockERC20();
        tokenRewards = new MockERC20();

        vm.prank(owner);
        simplewallet = new SimpleWallet(address(token), address(tokenRewards), 1 days);

        totalSupplytokenRewards = 1000000 * 1e18;
        tokenRewards.mint(address(simplewallet), totalSupplytokenRewards);
    }

    function test_setup() public {
        assertEq(simplewallet.isOwner(), owner);
        assertEq(token.balanceOf(address(simplewallet)), 0);
        assertEq(tokenRewards.balanceOf(address(simplewallet)), totalSupplytokenRewards);
        assertEq(simplewallet.getDuration(), 1 days);
    }

    function test_deposit_withdraw() public {
        address user1 = vm.addr(2);
        
        vm.startPrank(user1);
        token.mint(user1, 10 * 1e18);
        token.approve(address(simplewallet), 10 * 1e18);
        token.allowance(user1, address(simplewallet));

        simplewallet.deposit(10 * 1e18);
        assertEq(simplewallet.getBalance(), 10 * 1e18);
        assertEq(simplewallet.getBalance(), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(user1), 0);

        simplewallet.withdraw(10 * 1e18);
        assertEq(simplewallet.getBalance(), 0);
        assertEq(simplewallet.getBalance(), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(user1), 10 * 1e18);
    }

    function test_deposit_staking_claim() public {
        address user1 = vm.addr(2);
        
        vm.startPrank(user1);
        token.mint(user1, 10 * 1e18);
        token.approve(address(simplewallet), 10 * 1e18);
        token.allowance(user1, address(simplewallet));

        simplewallet.deposit(10 * 1e18);
        assertEq(simplewallet.getBalance(), 10 * 1e18);
        assertEq(simplewallet.getBalance(), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(user1), 0);

        vm.expectRevert();
        simplewallet.staking(11 * 1e18);
        simplewallet.staking(10 * 1e18);
        assertEq(simplewallet.getBalance(), 0);
        assertEq(simplewallet.getTotalWalletsFunds(), 10 * 1e18);
        assertEq(simplewallet.getStaking(), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(simplewallet.getTotalStaking(), 10 * 1e18);

        vm.warp(block.timestamp + 100);
        vm.expectRevert();
        simplewallet.claimRewards();
        assertTrue(!simplewallet.isClaiming());
        
        vm.warp(block.timestamp + 10000);
        vm.expectRevert();
        simplewallet.claimRewards();
        assertTrue(!simplewallet.isClaiming());

        vm.warp(block.timestamp + 1 days);
        simplewallet.claimRewards();
        assertTrue(simplewallet.isClaiming());
        assertEq(simplewallet.getBalance(), 10 * 1e18);
        assertEq(simplewallet.getStaking(), 0);
        assertEq(simplewallet.getTotalStaking(), 0);
        assertEq(tokenRewards.balanceOf(user1), 10 * 1e18);
    }

    function test_changeDuration() public {
        address user1 = vm.addr(2);

        assertEq(simplewallet.getDuration(), 1 days);

        vm.prank(user1);
        vm.expectRevert();
        simplewallet.changeDuration(2 days);

        vm.prank(owner);
        simplewallet.changeDuration(3 days);
        assertEq(simplewallet.getDuration(), 3 days);
    }

    function test_publicView() public {
        address user1 = vm.addr(2);

        assertEq(simplewallet.getToken(), address(token));
        assertEq(simplewallet.getTokenRewards(), address(tokenRewards));
    }

    function test_transaction() public {
        address user1 = vm.addr(2);
        address user2 = vm.addr(3);

        vm.startPrank(user1);
        token.mint(user1, 10 * 1e18);
        token.approve(address(simplewallet), 10 * 1e18);
        token.allowance(user1, address(simplewallet));

        simplewallet.deposit(10 * 1e18);
        assertEq(simplewallet.getBalance(), 10 * 1e18);
        assertEq(simplewallet.getBalance(), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(user1), 0);
        vm.stopPrank();

        vm.startPrank(user2);
        token.mint(user2, 10 * 1e18);
        token.approve(address(simplewallet), 10 * 1e18);
        token.allowance(user2, address(simplewallet));

        simplewallet.deposit(10 * 1e18);
        assertEq(simplewallet.getBalance(), 10 * 1e18);
        assertEq(simplewallet.getTotalWalletsFunds(), 20 * 1e18);
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        assertEq(token.balanceOf(user2), 0);
        vm.stopPrank();

        vm.startPrank(user1);
        simplewallet.transaction(user2, 5 * 1e18);
        assertEq(simplewallet.getBalance(), 5 * 1e18);
        assertEq(simplewallet.getTotalWalletsFunds(), 20 * 1e18);
        assertEq(token.balanceOf(address(simplewallet)), simplewallet.getTotalWalletsFunds());
        vm.stopPrank();

        vm.startPrank(user2);
        assertEq(simplewallet.getBalance(), 15 * 1e18);
    }
}
