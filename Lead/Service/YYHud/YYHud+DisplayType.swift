//
//  YYHud+ShowType.swift
//  SwiftProject
//
//  Created by yangyuan on 2018/8/9.
//  Copyright © 2018年 huan. All rights reserved.
//

import UIKit

public extension YYHud {
	public enum DisplayType {
		case tip(text: String)
		case loading(text: String?)
		case image(image: UIImage, text: String?)
	}
}

public extension YYHud {
	static var imageSucess: UIImage { return UIImage(named: "YYHudSucess")! }
	static var imageError: UIImage { return UIImage(named: "YYHudError")! }
	static var imageInfo: UIImage { return UIImage(named: "YYHudInfo")! }
	
	///
	public class ContentView: UIView {
		///
		lazy var textLabel: UILabel = {
			let lable = UILabel()
			lable.numberOfLines = 0
			lable.font = .systemFont(ofSize: 14)
			lable.textColor = #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
			lable.textAlignment = .center
			
			return lable
		}()
		
		lazy var indicatorView: UIActivityIndicatorView = {
			let view = UIActivityIndicatorView(style: .whiteLarge)
			view.hidesWhenStopped = false
			
			return view
		}()
		
		lazy var imageView: UIImageView = {
			let view = UIImageView()
			view.contentMode = .scaleAspectFit
			
			return view
		}()
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			setupContext()
		}
		
		required public init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func setupContext() {
			backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7491705908)
			cornerRadius = 5
		}
		
		func config(with type: DisplayType) {
			removeSubviews()
			switch type {
			case .tip(let text):
				showTip(text)
			case .loading(let text):
				showLoading(text)
			case let .image(image, text):
				showImage(image, text: text)
			}
		}
		
		func showTip(_ text: String) {
			addSubview(textLabel)
			textLabel.text = text
			textLabel.layoutEqualParent(12)
		}
		
		func showLoading(_ text: String?) {
			addSubview(indicatorView)
			indicatorView.startAnimating()
			if let text = text, text.count > 0 {
				addSubview(textLabel)
				textLabel.text = text
				
				indicatorView.layoutTopParent(12)
				indicatorView.layoutCenterHorizontal()
				textLabel.layoutVertical(view: indicatorView, offset: 5)
				textLabel.layoutLeftParent(15)
				textLabel.layoutRightParent(15)
				textLabel.layoutBottomParent(9)
				textLabel.layoutWidth(min: 50)
			} else {
				indicatorView.layoutEqualParent(15)
			}
		}
		
		func showImage(_ image: UIImage, text: String?) {
			addSubview(imageView)
			imageView.image = image
			if let text = text, text.count > 0 {
				addSubview(textLabel)
				textLabel.text = text
				
				imageView.layoutTopParent(12)
				imageView.layoutCenterHorizontal()
				textLabel.layoutVertical(view: imageView, offset: 5)
				textLabel.layoutLeftParent(15)
				textLabel.layoutRightParent(15)
				textLabel.layoutBottomParent(9)
				textLabel.layoutWidth(min: 50)
			} else {
				imageView.layoutEqualParent(15)
			}
		}
	}
}
