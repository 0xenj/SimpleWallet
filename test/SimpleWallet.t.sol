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
        assertGe(token.balanceOf(user1), 0);

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
        assertGe(token.balanceOf(user1), 0);

        vm.expectRevert();
        simplewallet.stacking(11 * 1e18);
        simplewallet.staking(10 * 1e18);
        
    }
}
