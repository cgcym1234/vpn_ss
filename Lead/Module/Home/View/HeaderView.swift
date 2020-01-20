//
//  HeaderView.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import UIKit
import RxSwift

class HeaderView: UIView {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var button: UIButton!
    
    var viewModel: HeaderViewModel!
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupContext()
    }
    
    func setupContext() {
        viewModel = HeaderViewModel()
        
        viewModel.status.share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] in
                self?.setup(with: $0)
            })
            .disposed(by: bag)
        
        viewModel.config.share(replay: 1, scope: .whileConnected)
            .subscribe(onNext: { [weak self] in
                self?.setup(with: $0)
            })
            .disposed(by: bag)
        
        button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.didTapButton()
            })
            .disposed(by: bag)
    }
    
    func setup(with status: VPNManager.Status) {
        indicator.stopAnimating()
        button.isUserInteractionEnabled = true
        button.backgroundColor = .clear
        button.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)

        switch status {
        case .off:
            button.setTitle("点击连接", for: .normal)
        case .on:
            button.setTitle("已连接", for: .normal)
            button.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            button.setTitleColor(.white, for: .normal)
        case .connecting:
            button.setTitle("正在连接...", for: .normal)
            button.isUserInteractionEnabled = false
            indicator.startAnimating()
        default:
            button.isUserInteractionEnabled = false
            indicator.startAnimating()
        }
    }
    
    func setup(with config: VPNManager.Config?) {
        nameLabel.text = config?.name ?? "未选择配置"
        nameLabel.textColor = config == nil ? #colorLiteral(red: 0.5960784314, green: 0.5960784314, blue: 0.6156862745, alpha: 1) : .black
    }
    
    func didTapButton() {
        if VPNManager.shared.status == .off {
            if let config = viewModel.config.value {
                VPNManager.shared.connect(with: config)
            } else {
                YYHud.showTip("未选择配置")
            }
        } else {
            VPNManager.shared.disconnect()
        }
    }
}
