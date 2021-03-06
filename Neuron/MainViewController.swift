//
//  MainViewController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/18.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        applyStyle()
        addNativeTokenMsgToRealm()
    }

    // get native token for nervos  'just temporary'
    func addNativeTokenMsgToRealm() {
        let appModel = AppModel.current
        let ethModel = TokenModel()
        ethModel.address = ""
        ethModel.chainId = NativeChainId.ethMainnetChainId
        ethModel.chainName = ""
        ethModel.decimals = NativeDecimals.nativeTokenDecimals
        ethModel.iconUrl = ""
        ethModel.isNativeToken = true
        ethModel.name = "ethereum"
        ethModel.symbol = "ETH"

        if let id = TokenModel.identifier(for: ethModel) {
            ethModel.identifier = id
        }

        let realm = try! Realm()
        try? realm.write {
            realm.add(ethModel, update: true)
            if !appModel.nativeTokenList.contains(ethModel) {
                appModel.nativeTokenList.append(ethModel)
                realm.add(appModel)
            }
        }

        // Add mba token
        DispatchQueue.global().async {
            let mbaHost = "http://testnet.mba.cmbchina.biz:1337"
            do {
                let metaData = try AppChainNetwork.appChain(url: URL(string: mbaHost)!).rpc.getMetaData()
                let realm = try Realm()
                let appModel = realm.objects(AppModel.self).first!
                guard !appModel.nativeTokenList.contains(where: {
                    $0.chainId == metaData.chainId && $0.chainHosts == mbaHost && $0.symbol == metaData.tokenSymbol
                }) else { return }

                let tokenModel = TokenModel()
                tokenModel.chainId = metaData.chainId
                tokenModel.chainName = metaData.chainName
                tokenModel.symbol = metaData.tokenSymbol
                tokenModel.iconUrl = metaData.tokenAvatar
                tokenModel.name = metaData.tokenName
                tokenModel.chainHosts = mbaHost
                tokenModel.isNativeToken = true
                try realm.write {
                    appModel.nativeTokenList.append(tokenModel)
                }
            } catch {
            }
        }
    }

    private func applyStyle() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "tint_color")!], for: .selected)

        let navigationBarBackImage = UIImage(named: "nav_darkback")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = navigationBarBackImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = navigationBarBackImage

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
    }
}
