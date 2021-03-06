//
//  GasCalculator.swift
//  Neuron
//
//  Created by James Chen on 2018/11/07.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation
import AppChain
import BigInt

/// Get current gas price and estimated gas, calculate gas, etc.
/// Ether = Tx Fees = Gas Limit * Gas Price
struct GasCalculator {
    // Default to 20 Gwei (which is not very reasonable when Ethereum is under congestion)
    static let defaultGasPrice = BigUInt(20).toWei(from: .gwei)
    static let defaultGasLimit: UInt64 = 21_000

    var gasPrice: BigUInt
    var gasLimit: UInt64

    init(gasPrice: BigUInt = GasCalculator.defaultGasPrice, gasLimit: UInt64 = GasCalculator.defaultGasLimit) {
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }

    var txFee: BigUInt {
        return GasCalculator.txFee(gasPrice: gasPrice, gasLimit: gasLimit)
    }

    var txFeeNatural: Double {
        return GasCalculator.txFeeNatural(gasPrice: gasPrice, gasLimit: gasLimit)
    }

    /// Calculate tx fee (Wei) giving gas price and gas limit.
    /// - Parameters:
    ///   - gasPrice: Gas price as GWei.
    ///   - gasLimit: Gas limit.
    /// - Returns: Calculated tx fee with unit wei.
    static func txFee(gasPrice: BigUInt, gasLimit: UInt64 = GasCalculator.defaultGasLimit) -> BigUInt {
        return gasPrice * BigUInt(gasLimit)
    }

    /// Calculate tx fee (ETH) giving gas price and gas limit.
    static func txFeeNatural(gasPrice: BigUInt, gasLimit: UInt64 = GasCalculator.defaultGasLimit) -> Double {
        let fee = txFee(gasPrice: gasPrice, gasLimit: gasLimit)
        return Double(Web3Utils.formatToEthereumUnits(fee, toUnits: .eth, decimals: 10)!)!
    }

    // TODO: provide estimate gas functionality
}

struct GasPriceFetcher {
    /// Get current gas price (Ethere Gwei)
    func gasPrice() -> BigUInt {
        do {
            return try EthereumNetwork().getWeb3().eth.getGasPrice()
        } catch {
            return GasCalculator.defaultGasPrice
        }
    }

    /// Get current quota price (CITA quota)
    func quotaPrice(rpcNode: String? = nil) -> BigUInt {
        do {
            let appChain: AppChain
            if let rpcNode = rpcNode, let rpcURL = URL(string: rpcNode) {
                appChain = AppChainNetwork.appChain(url: rpcURL)
            } else {
                appChain = AppChainNetwork.appChain()
            }
            return try Utils.getQuotaPrice(appChain: appChain)
        } catch {
            return GasCalculator.defaultGasPrice
        }
    }

    /// Get current gas price asynchronously
    func fetchGasPrice(then: @escaping (BigUInt) -> Void) {
        DispatchQueue.global().async {
            let price = self.gasPrice()
            DispatchQueue.main.async {
                then(price)
            }
        }
    }

    /// Get current quota price asynchronously
    func fetchQuotaPrice(rpcNode: String? = nil, then: @escaping (BigUInt) -> Void) {
        DispatchQueue.global().async {
            let price = self.quotaPrice(rpcNode: rpcNode)
            DispatchQueue.main.async {
                then(price)
            }
        }
    }
}
