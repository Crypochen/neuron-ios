//
//  String+Extension.swift
//  Neuron
//
//  Created by Yate Fulham on 2018/08/23.
//  Copyright © 2018 Cryptape. All rights reserved.
//

import Foundation

extension String {
    func removeHexPrefix() -> String {
        if self.hasPrefix("0x") {
            let indexStart = self.index(self.startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }

    func addHexPrefix() -> String {
        if self.hasPrefix("0x") {
            return self
        }
        return "0x" + self
    }
}
