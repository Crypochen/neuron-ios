//
//  AssetTableViewCell.swift
//  Neuron
//
//  Created by XiaoLu on 2018/5/23.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit
import SDWebImage

protocol AssetTableViewCellDelegate: class {
    func selectAsset(_ assetTableViewCell: UITableViewCell, didSelectAsset switch: UISwitch)
}

class AssetTableViewCell: UITableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var statusBtn: UISwitch!
    weak var delegate: AssetTableViewCellDelegate?

    var isSelect: Bool = false {
        didSet {
            if isSelect {
                statusBtn.isOn = true
            } else {
                statusBtn.isOn = false
            }
        }
    }

    var iconUrlStr: String? {
        didSet {
            iconImage.sd_setImage(with: URL(string: iconUrlStr!), placeholderImage: UIImage.init(named: "ETH_test"), options: .retryFailed, completed: nil)
        }
    }

    @IBAction func selectAssetSwitch(_ sender: UISwitch) {
        delegate?.selectAsset(self, didSelectAsset: sender)
    }
}
