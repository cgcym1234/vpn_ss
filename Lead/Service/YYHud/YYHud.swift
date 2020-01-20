//
//  YYHud.swift
//  SwiftSum
//
//  Created by sihuan on 16/5/11.
//  Copyright © 2016年 sihuan. All rights reserved.
//

import UIKit

// MARK: - Public
public extension YYHud {
	@discardableResult
	public static func showTip(_ text: String, duration: Double, in view: UIView? = nil) -> YYHud {
		return showTip(text, options: [.duration(second: duration)], in: view)
	}
	
	@discardableResult
	public static func showTip(_ text: String, options: OptionInfo = [.duration(second: 2)], in view: UIView? = nil) -> YYHud {
		return show(.tip(text: text), options: options, in: view)
	}
	
	@discardableResult
	public static func showLoading(with text: String? = nil, options: OptionInfo = [], in view: UIView? = nil) -> YYHud {
		return show(.loading(text: text), options: options, in: view)
	}
	
	@discardableResult
	public static func showSuccess(with text: String? = nil, options: OptionInfo = [.duration(second: 2)], in view: UIView? = nil) -> YYHud {
		return show(.image(image: YYHud.imageSucess, text: text), options: options, in: view)
	}
	
	@discardableResult
	public static func showError(with text: String? = nil, options: OptionInfo = [.duration(second: 2)], in view: UIView? = nil) -> YYHud {
		return show(.image(image: YYHud.imageError, text: text), options: options, in: view)
	}
	
	@discardableResult
	public static func showInfo(with text: String? = nil, options: OptionInfo = [.duration(second: 2)], in view: UIView? = nil) -> YYHud {
		return show(.image(image: YYHud.imageInfo, text: text), options: options, in: view)
	}
	
	@discardableResult
	public static func show(_ type: DisplayType, options: OptionInfo = [], in view: UIView? = nil) -> YYHud {
		return YYHud.default.show(type, options: options, in: view)
	}
	
	public static func dismiss(after: Double = 0) {
		YYHud.default.dismiss(after: after)
	}
}

public final class YYHud: UIView {
	
	public static let `default` = YYHud()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupContext()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupContext() {
		autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
	
	private var dismissTimer: Timer?
	
	private lazy var contentView: ContentView = {
		let v = ContentView()
		addSubview(v)
		v.layoutCenterParent()
		v.layoutWidth(max: width/4 * 3)
		v.layoutHeight(max: height/4 * 3)
		
		return v
	}()
}

public extension YYHud {
	@discardableResult
	public func show(_ type: DisplayType, options: OptionInfo = [], in view: UIView? = nil) -> YYHud {
		config(with: view)
		config(with: type)
		config(with: options)
		
		return self.showAnimated()
	}
	
	public func dismiss(after: Double = 0) {
		if after > 0 {
			dismissTimer?.invalidate()
			dismissTimer = Timer.scheduledTimer(timeInterval: after, target: self, selector: #selector(dismissAnimated), userInfo: nil, repeats: false)
		} else {
			dismissAnimated()
		}
	}
}

private extension YYHud {
	var defaultWindow: UIWindow {
		return UIApplication.shared.delegate!.window!!
	}
	
	func config(with view: UIView?) {
		let superView = view ?? defaultWindow
		removeFromSuperview()
		superView.addSubview(self)
		frame = superView.bounds
	}
	
	func config(with type: DisplayType) {
		contentView.config(with: type)
	}
	
	func config(with options: OptionInfo) {
		backgroundColor = options.isDim ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5) : .clear
		isUserInteractionEnabled = options.isModal ? true : false
		dismissTimer?.invalidate()
		options.duration.unwrapped {
			self.dismiss(after: $0)
		}
	}
}

private extension YYHud {
	func showAnimated() -> Self {
		contentView.alpha = 0
		UIView.animate(withDuration: 0.35) {
			self.contentView.alpha = 1
		}
		return self
	}
	
	@objc func dismissAnimated() {
		UIView.animate(withDuration: 0.35, animations: {
			self.contentView.alpha = 0
		}) { (_) in
			self.removeFromSuperview()
		}
	}
}


















