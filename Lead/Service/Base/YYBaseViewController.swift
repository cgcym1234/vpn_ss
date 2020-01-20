//
//  YYBaseViewController.swift
//  SwiftProject
//
//  Created by yangyuan on 2018/4/8.
//  Copyright © 2018年 huan. All rights reserved.
//

import UIKit
import RxSwift

open class YYBaseViewController: UIViewController {
	
	public var rxBag = DisposeBag()
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		
		setupViews()
		setupLayout()
		setupBinds()
		setupContext()
	}
	
	open func setupContext() {
//        extendedLayoutAll()
	}
	
	open func setupViews() {}
	open func setupLayout() {}
	open func setupBinds() {}
	
	deinit {
	}
}
