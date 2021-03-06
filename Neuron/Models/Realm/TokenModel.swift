//
//  TokenModel.swift
//  Neuron
//
//  Created by XiaoLu on 2018/7/2.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

class TokenModel: Object, Decodable {
    @objc dynamic var name = ""
    @objc dynamic var iconUrl: String? = ""
    @objc dynamic var address = ""
    @objc dynamic var decimals = 18
    @objc dynamic var symbol = ""
    @objc dynamic var chainName: String? = ""
    @objc dynamic var chainId = ""
    @objc dynamic var chainHosts = "" // manifest.json chainSet.values.first
    @objc dynamic var identifier = UUID().uuidString

    // defaults false, eth and RPC "getMateData" is true.
    @objc dynamic var isNativeToken = false // TODO: AppChain ERC20 should not be marked as native token.

    @objc dynamic var balanceText = "0"
    var currencyAmount = "0"

    var balance: BigUInt {
        get {
            return BigUInt.parseToBigUInt(balanceText, decimals)
        }
        set {
            balanceText = newValue.toDecimalNumber(decimals).formatterToString(decimals)
        }
    }

    override class func primaryKey() -> String? {
        return "identifier"
    }

    override static func ignoredProperties() -> [String] {
        return ["currencyAmount"]
    }

    struct Logo: Decodable {
        var src: String?
    }
    var logo: Logo?

    var type: TokenType {
        if isNativeToken {
            if chainId == NativeChainId.ethMainnetChainId {
                return .ether
            } else {
                if address != "" {
                    return .appChainErc20
                } else {
                    return .appChain
                }
            }
        } else {
            return .erc20
        }
    }
    var gasSymbol: String {
        switch type {
        case .ether, .erc20:
            return "ETH"
        case .appChain, .appChainErc20:
            return self.symbol
        }
    }

    var isEthereum: Bool {
        return type == .ether || type == .erc20
    }

    enum CodingKeys: String, CodingKey {
        case name
        case address
        case decimals
        case symbol
        case logo
    }
}

extension TokenModel {
    static func identifier(for tokenModel: TokenModel) -> String? {
        let appModel = AppModel.current
        var tokenList: [TokenModel] = []
        tokenList += appModel.nativeTokenList
        tokenList += appModel.extraTokenList
        if let model = tokenList.first(where: { $0 == tokenModel }) {
            return model.identifier
        }
        return nil
    }
}

extension TokenModel {
    public static func == (lhs: TokenModel, rhs: TokenModel) -> Bool {
        return lhs.chainId == rhs.chainId && lhs.symbol == rhs.symbol && lhs.name == rhs.name
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenModel else { return false }
        return object.address == address
    }
}
