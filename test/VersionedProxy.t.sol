// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {VersionedImplementation} from "../src/VersionedImplementation.sol";
import {VersionedProxy} from "../src/VersionedProxy.sol";

contract VersionedProxyTest is Test {
    VersionedImplementation public implementation;
    VersionedProxy public proxy;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        
        implementation = new VersionedImplementation();
        proxy = new VersionedProxy(address(implementation));
        
        // Initialize through the proxy
        //VersionedImplementation(address(proxy)).initialize(owner);
    }

    function testInitialState() public {
        require(proxy.getCurrentVersion() == address(implementation), "Current version mismatch");
        require(proxy.versionHistory(0) == address(implementation), "Version history mismatch");
        require(proxy.currentVersionIndex() == 0, "Version index mismatch");
    }

    function testUpgrade() public {
        vm.prank(owner);
        VersionedImplementation newImplementation = new VersionedImplementation();
        proxy.upgradeTo(address(newImplementation));
        
        // Initialize through the proxy
        //VersionedImplementation(address(proxy)).initialize(owner);
        
        require(proxy.getCurrentVersion() == address(newImplementation), "Current version mismatch");
        require(proxy.versionHistory(1) == address(newImplementation), "Version history mismatch");
        require(proxy.currentVersionIndex() == 1, "Version index mismatch");
    }

    function testRollback() public {
        vm.prank(owner);
        VersionedImplementation newImplementation = new VersionedImplementation();
        proxy.upgradeTo(address(newImplementation));
        
        // Initialize through the proxy
        //VersionedImplementation(address(proxy)).initialize(owner);
        
        proxy.rollbackTo(0);
        
        require(proxy.getCurrentVersion() == address(implementation), "Current version mismatch");
        require(proxy.currentVersionIndex() == 0, "Version index mismatch");
    }

    function testSetValue() public {
        vm.prank(user);
        VersionedImplementation(address(proxy)).setValue(100);
        require(VersionedImplementation(address(proxy)).value() == 100, "Value mismatch");
    }

    function test_RevertWhen_UpgradingToSameImplementation() public {
        vm.expectRevert("New implementation is the same as current");
        proxy.upgradeTo(address(implementation));
    }

    function test_RevertWhen_RollingBackToInvalidIndex() public {
        vm.expectRevert("Version index out of bounds");
        proxy.rollbackTo(1);
    }

    function test_RevertWhen_NonOwnerUpgrades() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), user));
        proxy.upgradeTo(address(0x2));
    }

    function test_RevertWhen_NonOwnerRollsBack() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(bytes4(keccak256("OwnableUnauthorizedAccount(address)")), user));
        proxy.rollbackTo(0);
    }
} 