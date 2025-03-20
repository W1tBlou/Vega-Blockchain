// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "./VersionedImplementation.sol";

contract VersionedProxy is ERC1967Proxy, Ownable {
    address[] public versionHistory;
    uint256 public currentVersionIndex;

    event VersionAdded(address indexed implementation, uint256 versionIndex);
    event VersionUpgraded(address indexed oldImplementation, address indexed newImplementation);
    event VersionRolledBack(address indexed implementation, uint256 versionIndex);

    constructor(address _implementation) ERC1967Proxy(_implementation, "") Ownable(msg.sender) {
        require(_implementation != address(0), "Invalid implementation address");
        versionHistory.push(_implementation);
        currentVersionIndex = 0;
    }

    function getCurrentVersion() public view returns (address) {
        return versionHistory[currentVersionIndex];
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        require(newImplementation != address(0), "Invalid implementation address");
        require(newImplementation != getCurrentVersion(), "New implementation is the same as current");
        
        address oldImplementation = getCurrentVersion();
        
        // First upgrade the implementation
        ERC1967Utils.upgradeToAndCall(newImplementation, "");
        
        // Then update our version history
        versionHistory.push(newImplementation);
        currentVersionIndex = versionHistory.length - 1;
        
        emit VersionAdded(newImplementation, currentVersionIndex);
        emit VersionUpgraded(oldImplementation, newImplementation);
    }

    function rollbackTo(uint256 versionIndex) external onlyOwner {
        require(versionIndex < versionHistory.length, "Version index out of bounds");
        require(versionIndex != currentVersionIndex, "Already at this version");
        
        address oldImplementation = getCurrentVersion();
        address newImplementation = versionHistory[versionIndex];
        
        // First upgrade the implementation
        ERC1967Utils.upgradeToAndCall(newImplementation, "");
        
        // Then update our version index
        currentVersionIndex = versionIndex;
        
        emit VersionRolledBack(newImplementation, versionIndex);
    }

    function getVersionHistory() external view returns (address[] memory) {
        return versionHistory;
    }
} 