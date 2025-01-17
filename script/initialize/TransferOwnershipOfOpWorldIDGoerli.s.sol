// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

// demo deployments

import {Script} from "forge-std/Script.sol";
import {OpWorldID} from "../../src/OpWorldID.sol";
import {ICrossDomainMessenger} from
    "@eth-optimism/contracts/libraries/bridge/ICrossDomainMessenger.sol";
import {ICrossDomainOwnable3} from "../../src/interfaces/ICrossDomainOwnable3.sol";

/// @notice Initializes the StateBridge contract
contract TransferOwnershipOfOpWorldIDGoerli is Script {
    address public stateBridgeAddress;
    address public opWorldIDAddress;
    address public immutable crossDomainMessengerAddress;
    uint256 public privateKey;

    OpWorldID public opWorldID;

    /// @notice in CrossDomainOwnable3.sol, isLocal is used to set ownership to a new address with a toggle
    /// for local or cross domain (using the CrossDomainMessenger to pass messages)
    bool public isLocal;

    function setUp() public {
        /*//////////////////////////////////////////////////////////////
                                 CONFIG
        //////////////////////////////////////////////////////////////*/
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/.deploy-config.json");
        string memory json = vm.readFile(path);

        privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
        opWorldIDAddress = abi.decode(vm.parseJson(json, ".optimismWorldIDAddress"), (address));
        stateBridgeAddress = abi.decode(vm.parseJson(json, ".stateBridgeAddress"), (address));
    }

    constructor() {
        /*//////////////////////////////////////////////////////////////
                                 GOERLI
        //////////////////////////////////////////////////////////////*/
        crossDomainMessengerAddress = address(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);
    }

    function run() public {
        /// @notice cross domain ownership flag
        /// false = cross domain (address on Ethereum)
        /// true = local (address on Optimism)
        isLocal = false;

        vm.startBroadcast(privateKey);

        transferOwnershipToStateBridge(stateBridgeAddress, isLocal);

        vm.stopBroadcast();
    }

    function transferOwnershipToStateBridge(address newOwner, bool _isLocal) internal {
        ICrossDomainOwnable3(opWorldIDAddress).transferOwnership(newOwner, _isLocal);
    }
}
