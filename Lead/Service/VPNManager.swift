//
//  VPNManager.swift
//  Hunting
//
//  Created by yuany on 2019/3/9.
//  Copyright © 2019 yuany. All rights reserved.
//

import Foundation
import NetworkExtension

extension VPNManager {
    enum Status {
        case off
        case connecting
        case on
        case disconnecting
        
        static let notification = "ProxyServiceVPNStatusNotification"
    }
    
    public enum Crypto: String, Codable, CaseIterable {
        case AES128CFB
        case AES192CFB
        case AES256CFB
        case CHACHA20
        case SALSA20
        case RC4MD5
    }
    
    class Config: Codable {
        let id: String
        var name: String
        var address: String
        var port: Int
        var crypto: Crypto
        var password: String
        var isSelected = false
        
        init(name: String, address: String, port: Int, crypto: Crypto, password: String) {
            self.id = App.timestampId
            self.name = name
            self.address = address
            self.port = port
            self.crypto = crypto
            self.password = password
        }
        
        func update(with model: Config) {
            self.name = model.name
            self.address = model.address
            self.port = model.port
            self.crypto = model.crypto
            self.password = model.password
        }
        
        func asDict() -> [String: Any] {
            return [
                "ss_address": address,
                "ss_port": port,
                "ss_crypto": crypto.rawValue,
                "ss_password": password,
                "ymal_conf": VPNManager.shared.ruleConf
            ]
        }
    }
}

extension VPNManager {
    func connect(with config: Config) {
        self.config = config
        loadAndCreateProviderManager { manager in
            if let manager = manager {
                do {
                    try manager.connection.startVPNTunnel(options: [:])
                } catch {
                    YYHud.showTip(error.localizedDescription)
                }
            }
        }
    }
    
    func disconnect(){
        loadProviderManager { $0?.connection.stopVPNTunnel() }
    }
}

public final class VPNManager {
    static let shared = VPNManager()
    
    private var config: Config!
    
    private(set) var status: Status = .off {
        didSet {
             NotificationCenter.default.post(name: Notification.Name(rawValue: VPNManager.Status.notification), object: nil)
        }
    }
    
    lazy fileprivate var ruleConf: String = {
        let path = Bundle.main.path(forResource: "NEKitRule", ofType: "conf")!
        let data = try! Foundation.Data(contentsOf: URL(fileURLWithPath: path))
        let str = String(data: data, encoding: String.Encoding.utf8)!
        return str
    }()
    
    init() {
        check()
        addStatusObserver()
    }
    
    func check() {
        loadProviderManager {
            guard let manager = $0 else { return }
            self.updateVPNStatus(manager)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension VPNManager {
    private func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "Hunting"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "Hunting VPN"
        
        return manager
    }
    
    func loadProviderManager(_ complition: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            complition(managers?.first)
        }
    }
    
    func loadAndCreateProviderManager(_ complition: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let managers = managers else { return }
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                managers.deleteDupConfig()
            }else{
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            manager.setConfig(self.config)
            manager.saveToPreferences {
                if let error = $0 {
                    YYHud.showTip(error.localizedDescription)
                    complition(nil)
                } else {
                    manager.loadFromPreferences { e in
                        if let err = e {
                            YYHud.showTip(err.localizedDescription)
                            complition(nil)
                        } else {
                            self.addStatusObserver()
                            complition(manager)
                        }
                    }
                }
            }
        }
    }
}

extension VPNManager {
    private func addStatusObserver() {
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                NotificationCenter.default.removeObserver(self)
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                })
            }
        }
    }
    
    private func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.status = .on
        case .connecting, .reasserting:
            self.status = .connecting
        case .disconnecting:
            self.status = .disconnecting
        case .disconnected, .invalid:
            self.status = .off
        }
        print(status)
    }
}

extension NETunnelProviderManager {
    func setConfig(_ config: VPNManager.Config) {
        guard let originConfig = protocolConfiguration as? NETunnelProviderProtocol else {
            return
        }
        
        originConfig.providerConfiguration = config.asDict()
//        let proxy = NEProxySettings()
//        proxy.autoProxyConfigurationEnabled = true
//        proxy.proxyAutoConfigurationURL = URL(string: "http://\(config.address)/pac")
//        originConfig.proxySettings = proxy
        protocolConfiguration = originConfig
    }
}

extension Array where Element: NETunnelProviderManager {
    func deleteDupConfig() {
        guard count > 1 else { return }
        
        forEach {
            $0.removeFromPreferences { error in
                _ = error.map { YYHud.showTip($0.localizedDescription) }
            }
        }
    }
}

