//
//  DataManager.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class DataManager {
    static let shared = DataManager()
    let configsKey = "configsKey"
    
    var configs: [VPNManager.Config] = []
    
    lazy var rxConfigs: BehaviorRelay<[VPNManager.Config]> = {
        return BehaviorRelay(value: configs)
    }()
    
    lazy var selectedConfig: BehaviorRelay<VPNManager.Config?> = {
        return BehaviorRelay(value: configs.filter{ $0.isSelected }.first)
    }()
    
    init() {
        configs = loadConfig()
    }
    
    private func loadConfig() -> [VPNManager.Config] {
        return UserDefaults.standard.object([VPNManager.Config].self, forKey: configsKey) ?? []
    }
    
    private func save() {
        UserDefaults.standard.set(object: configs, forKey: configsKey)
        notify()
    }
    
    private func notify() {
        rxConfigs.accept(configs)
        selectedConfig.accept(configs.filter{ $0.isSelected }.first)
    }
    
    func addConfig(_ config: VPNManager.Config) {
        configs.append(config)
        if configs.count == 1 {
            selecteConfig(config)
        } else {
            save()
        }
    }
    
    func deleteConfig(_ config: VPNManager.Config) {
        let newConfigs = configs.filter { $0.id != config.id }
        if newConfigs.count != configs.count {
            configs = newConfigs
            save()
        }
    }
    
    func selecteConfig(_ config: VPNManager.Config) {
        guard let selected = configs.filter({ $0.id == config.id }).first,
        !selected.isSelected else {
            return
        }
        
        configs.forEach {
            $0.isSelected = false
        }
        
        selected.isSelected = true
        save()
    }
    
    func updateConfig(_ config: VPNManager.Config) {
        var index = -1
        for i in 0..<configs.count {
            if configs[i].id == config.id {
                index = i
                break
            }
        }
        
        if index != -1 {
            configs[index] = config
            save()
        }
    }
}
