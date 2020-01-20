//
//  HeaderViewModel.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class HeaderViewModel {
    var rxBag = DisposeBag()
    
    let config: BehaviorRelay<VPNManager.Config?> = BehaviorRelay(value: nil)
    let status: BehaviorRelay<VPNManager.Status> = BehaviorRelay(value: .off)
    
    init() {
        DataManager.shared.selectedConfig
            .share(replay: 1, scope: .whileConnected)
            .bind(to: self.config)
            .disposed(by: rxBag)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: VPNManager.Status.notification), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            self?.status.accept(VPNManager.shared.status)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
