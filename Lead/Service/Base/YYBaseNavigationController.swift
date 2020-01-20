//
//  YYBaseNavigationController.swift
//  SwiftProject
//
//  Created by yangyuan on 2018/4/8.
//  Copyright © 2018年 huan. All rights reserved.
//

import UIKit

open class YYBaseNavigationController: UINavigationController {
	
	private var viewTransitionInProgress = false
	
	open override func viewDidLoad() {
		super.viewDidLoad()
		setupContext()
	}
	
	open func setupContext() {
		delegate = self
		navigationBar.isTranslucent = false
        
        navigationBar.setBackgroundImage(.image(withColor: #colorLiteral(red: 0.07843137255, green: 0.5568627451, blue: 1, alpha: 1)), for: .default)
        navigationBar.shadowImage = .image(withColor: .clear)
        navigationBar.titleTextAttributes = [
            .foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
            .font:UIFont.systemFont(ofSize: 18)
        ]
        navigationBar.tintColor = .white
        
	}
}

extension YYBaseNavigationController: UINavigationControllerDelegate {
	public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
	}
}

