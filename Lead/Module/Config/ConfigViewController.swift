//
//  ConfigViewController.swift
//  Lead
//
//  Created by yuany on 2019/3/12.
//  Copyright © 2019 yicheng. All rights reserved.
//

import UIKit

class ConfigViewController: UITableViewController {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var address: UITextField!
    @IBOutlet var port: UITextField!
    @IBOutlet var crypto: UITextField!
    @IBOutlet var password: UITextField!
    
    var config: VPNManager.Config?
    var cryptoMethod: VPNManager.Crypto? {
        didSet {
            crypto.text = cryptoMethod?.rawValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContext()
    }
    
    func setupContext() {
        title = "添加配置"
        crypto.delegate = self
        
        if let config = config {
            title = config.name
            name.text = config.name
            address.text = config.address
            port.text = String(config.port)
            crypto.text = config.crypto.rawValue
            password.text = config.password
        } else {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action:
//                #selector(cancel))
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action:
            #selector(done))
        tableView.clearExtraCellLine()
        
        let view = UIView()
        view.size = CGSize(width: 40, height: 22)
        
        let button = YYBaseButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "eye_open"), for: .selected)
        button.setImage(#imageLiteral(resourceName: "eye_close"), for: .normal)
        button.size = CGSize(width: 22, height: 22)
        button.addTarget(self, action: #selector(visibleButtonAction(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        password.rightView = view
        password.rightViewMode = .always
        
        password.isSecureTextEntry = true
    }
    
    @objc func visibleButtonAction(_ button: UIButton) {
        password.isSecureTextEntry = button.isSelected
        button.isSelected = !button.isSelected
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "加密方式", message: nil, preferredStyle: .actionSheet)
        for item in VPNManager.Crypto.allCases {
            actionSheet.addAction(title: item.rawValue, style: .default, isEnabled: true) { [weak self] _ in
                self?.cryptoMethod = item
            }
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func done() {
        guard let name = name.text,
            let address = address.text,
            let port = port.text,
            let crypto = self.cryptoMethod,
            let password = password.text,
            !name.isEmpty, !address.isEmpty,
            !port.isEmpty, !password.isEmpty else {
                YYHud.showTip("配置未完成!")
                return
        }
        
        let model = VPNManager.Config(name: name, address: address, port: Int(port) ?? 9103, crypto: crypto, password: password)
        
        if let config = config {
            config.update(with: model)
            DataManager.shared.updateConfig(config)
        } else {
            DataManager.shared.addConfig(model)
        }
        
        cancel()
    }
    
    @objc func cancel() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    static func push(with model: VPNManager.Config?) {
        guard let fromVC = UIViewController.appTopViewController else {
            return
        }
        
        let configVC = fromVC.storyboard!.instantiateViewController(ConfigViewController.self)
        configVC.config = model
        fromVC.navigationController?.pushViewController(configVC, animated: true)
    }
}

extension ConfigViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showActionSheet()
        return false
    }
}

extension ConfigViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 15 : 24
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        if section == 1 {
            let label = UILabel().then {
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                $0.text = "鉴定"
            }
            
            label.sizeToFit()
            label.x = 26
            view.addSubview(label)
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


extension UIAlertController {
    @discardableResult
    public func addAction(title: String,
                          style: UIAlertAction.Style = .default,
                          isEnabled: Bool = true,
                          handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.isEnabled = isEnabled
        addAction(action)
        return action
    }
}


open class YYBaseButton: UIButton {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds = self.bounds
        let widthDelta = max(54.0 - bounds.size.width, 0)
        let heightDelta = max(54.0 - bounds.size.height, 0)
        bounds = bounds.insetBy(dx: -0.5 * widthDelta, dy: -0.5 * heightDelta)
        return bounds.contains(point)
    }
}
