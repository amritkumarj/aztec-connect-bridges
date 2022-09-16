// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseDeployment} from "../base/BaseDeployment.s.sol";
import {DataProvider} from "../../aztec/DataProvider.sol";

contract DataProviderDeployment is BaseDeployment {
    function deploy() public returns (address) {
        emit log("Deploying Data Provider");

        vm.broadcast();
        DataProvider provider = new DataProvider(ROLLUP_PROCESSOR);
        emit log_named_address("Data provider deployed to", address(provider));

        return address(provider);
    }

    function read() public {
        // Todo: Replace address of data provider
        DataProvider provider = DataProvider(address(0));

        DataProvider.AssetData[] memory assets = provider.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            DataProvider.AssetData memory asset = assets[i];
            emit log_named_uint(asset.label, asset.assetId);
        }

        DataProvider.BridgeData[] memory bridges = provider.getBridges();
        for (uint256 i = 0; i < bridges.length; i++) {
            DataProvider.BridgeData memory bridge = bridges[i];
            if (bridge.bridgeAddressId != 0) {
                emit log_named_uint(bridge.label, bridge.bridgeAddressId);
            }
        }
    }

    function deployAndListMany() public {
        address provider = deploy();

        uint256[] memory assetIds = new uint256[](5);
        string[] memory assetTags = new string[](5);
        for (uint256 i = 0; i < 5; i++) {
            assetIds[i] = i;
        }
        assetTags[0] = "eth";
        assetTags[1] = "dai";
        assetTags[2] = "wsteth";
        assetTags[3] = "vydai";
        assetTags[4] = "vyweth";

        uint256[] memory bridgeAddressIds = new uint256[](5);
        string[] memory bridgeTags = new string[](5);

        bridgeAddressIds[0] = 1;
        bridgeAddressIds[1] = 6;
        bridgeAddressIds[2] = 7;
        bridgeAddressIds[3] = 8;
        bridgeAddressIds[4] = 9;

        bridgeTags[0] = "ElementBridge";
        bridgeTags[1] = "CurveStEthBridge";
        bridgeTags[2] = "YearnBridge_Deposit";
        bridgeTags[3] = "YearnBridge_Withdraw";
        bridgeTags[4] = "ElementBridge2M";

        vm.broadcast();
        DataProvider(provider).addAssetsAndBridges(assetIds, assetTags, bridgeAddressIds, bridgeTags);
    }

    function _listBridge(
        address _provider,
        uint256 _bridgeAddressId,
        string memory _tag
    ) internal {
        vm.broadcast();
        DataProvider(_provider).addBridge(_bridgeAddressId, _tag);
        emit log_named_uint(string(abi.encodePacked("[Bridge] Listed ", _tag, " at")), _bridgeAddressId);
    }

    function _listAsset(
        address _provider,
        uint256 _assetId,
        string memory _tag
    ) internal {
        vm.broadcast();
        DataProvider(_provider).addAsset(_assetId, _tag);
        emit log_named_uint(string(abi.encodePacked("[Asset]  Listed ", _tag, " at")), _assetId);
    }
}
