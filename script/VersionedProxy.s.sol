// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {VersionedImplementation} from "../src/VersionedImplementation.sol";
import {VersionedProxy} from "../src/VersionedProxy.sol";

contract VersionedProxyScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation
        VersionedImplementation implementation = new VersionedImplementation();
        console2.log("Implementation deployed at:", address(implementation));

        // Deploy proxy
        VersionedProxy proxy = new VersionedProxy(address(implementation));
        console2.log("Proxy deployed at:", address(proxy));

        console2.log("Contract initialized with owner:", deployer);

        // Log current version info
        console2.log("Current version:", proxy.getCurrentVersion());
        console2.log("Current version index:", proxy.currentVersionIndex());
        console2.log("Version history length:", proxy.currentVersionIndex() + 1);

        vm.stopBroadcast();
    }
} 