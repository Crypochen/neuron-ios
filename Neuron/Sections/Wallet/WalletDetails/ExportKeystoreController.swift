//
//  ExportKeystoreController.swift
//  Neuron
//
//  Created by XiaoLu on 2018/6/24.
//  Copyright © 2018年 cryptape. All rights reserved.
//

import UIKit

class ExportKeystoreController: UIViewController, EnterBackOverlayPresentable {
    @IBOutlet weak var kestoreTextView: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    var walletModel = WalletModel()
    var keystoreString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导出Keystore"
        walletModel = AppModel.current.currentWallet!
        kestoreTextView.text = keystoreString
        setupEnterBackOverlay()
    }

    @IBAction func didClickCopyButton(_ sender: UIButton) {
        UIPasteboard.general.string = keystoreString
        Toast.showToast(text: "Keystore已经复制到粘贴板")
    }
}
