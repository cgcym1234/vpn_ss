//
//  HomeViewModel.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Reusable

final class HomeViewModel {
    
    enum Section: Int {
        case configs = 0
    }
    
    let sectionNames = [
        "配置列表",
        ]
    
    var rxBag = DisposeBag()
    
    let dataManger: DataManager
    let notifyClosure: () -> Void
    
    var configs: [VPNManager.Config] {
        return dataManger.configs
    }
    
    init(dataManger: DataManager = .shared, notify: @escaping () -> Void) {
        self.dataManger = dataManger
        self.notifyClosure = notify
        
        dataManger.rxConfigs
            .share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] _ in
                self?.notifyClosure()
            })
            .disposed(by: rxBag)
        
        dataManger.selectedConfig
            .share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] _ in
                self?.notifyClosure()
            })
            .disposed(by: rxBag)
    }
    
    var numberOfSections: Int {
        return sectionNames.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if section == Section.configs.rawValue {
            return configs.count + 1
        }
        
        return 1
    }
    
    func cellForRow(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        let cell: UITableViewCell
        switch section {
        case .configs:
            if indexPath.row == configs.count {
                cell = tableView.dequeueReusableCell(for: indexPath, cellType: ConfigAddCell.self)
            } else {
                cell = tableView.dequeueReusableCell(for: indexPath, cellType: ConfigCell.self)
                    .render(with: config(at: indexPath.row))
                
            }
        }
        
        return cell
    }
    
    func config(at index: Int) -> VPNManager.Config {
        return configs[index]
    }
    
    func text(at section: Int) -> String {
        return sectionNames[section]
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        let section = Section(rawValue: indexPath.section)!
        switch section {
        case .configs:
            if indexPath.row == configs.count {
                ConfigViewController.push(with: nil)
            } else {
                DataManager.shared.selecteConfig(config(at: indexPath.row))
            }
        }
    }
    
    func accessoryButtonTapped(at indexPath: IndexPath) {
        if VPNManager.shared.status == .on {
            YYHud.showTip("请先断开当前连接")
            return
        }
        
        let model = config(at: indexPath.row)
        ConfigViewController.push(with: model)
    }
    
    func canEditRow(at indexPath: IndexPath) -> Bool {
        let section = Section(rawValue: indexPath.section)!
        if section == .configs, indexPath.row < configs.count {
            return VPNManager.shared.status != .on
        }
        
        return false
    }
    
    func deleteConfig(at indexPath: IndexPath) {
        dataManger.deleteConfig(config(at: indexPath.row))
    }
}
