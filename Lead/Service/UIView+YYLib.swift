//
//  UIView+YYLib.swift
//  SwiftProject
//
//  Created by yangyuan on 2018/2/7.
//  Copyright © 2018年 huan. All rights reserved.
//

import UIKit

public extension UIImage {
    /**
     Create and return a pure color image with the given color and size.
     
     @param color  The color.
     @param size   New image's type. default 1x1 point size
     */
    public static func image(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public extension UITableView {
    public func clearExtraCellLine() {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        tableFooterView = footerView
    }
}

public extension Optional {
    public func unwrapped(_ handler: (Wrapped) -> ()) {
        map(handler)
    }
    
    public func unwrapped(or defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
        // http://www.russbishop.net/improving-optionals
        return self ?? defaultValue()
    }
}


public extension NSObject {
    ///
    public static var clsName: String {
        return String(describing: self)
    }
    
    public var clsName: String {
        return type(of: self).clsName
    }
}

// MARK: - UIStoryboard
public extension UIStoryboard {
    public func instantiateViewController<T: UIViewController>(_ cls: T.Type) -> T {
        return instantiateViewController(withIdentifier: cls.clsName) as! T
    }
}

// MARK: - UIViewController
public extension UIViewController {
    class func instantiateFromStoryboard(_ named: String, id: String? = nil) -> Self {
        let controller = UIStoryboard(name: named, bundle: nil).instantiateViewController(withIdentifier: id ?? self.clsName)
        return unsafeDowncast(controller, to: self)
    }
    
    class func instantiateInitialFromStoryboard(_ named: String) -> Self {
        let controller = UIStoryboard(name: named, bundle: nil).instantiateInitialViewController()!
        return unsafeDowncast(controller, to: self)
    }
    
    public static var appTopViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topViewController
    }
    
    public var topViewController: UIViewController? {
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topViewController
        }
        if let tab = self as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.topViewController
            }
        }
        if let presented = presentedViewController {
            return presented.topViewController
        }
        return self
    }
}

// MARK: - Static
public extension UIView {
	/// 根据xib生成对象
	public class func instantiateFromNib() -> Self {
		return instantiateFromNibHelper()
	}
	
	/// https://stackoverflow.com/questions/33200035/return-instancetype-in-swift
	private class func instantiateFromNibHelper<T>() -> T {
		return Bundle(for: self).loadNibNamed(self.clsName, owner: nil, options: nil)!.first! as! T
	}
}

// MARK: - Convenience init
public extension UIView {
	/// EZSwiftExtensions
	public convenience init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
		self.init(frame: CGRect(x: x, y: y, width: w, height: h))
	}
	
	/// EZSwiftExtensions, puts padding around the view
	public convenience init(superView: UIView, padding: CGFloat) {
		self.init(frame: CGRect(x: superView.x + padding, y: superView.y + padding, width: superView.width - padding*2, height: superView.height - padding*2))
	}
	
	/// EZSwiftExtensions - Copies size of superview
	public convenience init(superView: UIView) {
		self.init(frame: CGRect(origin: CGPoint.zero, size: superView.size))
	}
}

// MARK: - Property
public extension UIView {
	/// Loops until it finds the top root view.
	public var rootView: UIView {
		guard let parentView = superview else {
			return self
		}

		return parentView.rootView
	}
	
	/// Get view's parent view controller
	public var parentViewController: UIViewController? {
		weak var parentResponder: UIResponder? = self
		while parentResponder != nil {
			parentResponder = parentResponder!.next
			if let viewController = parentResponder as? UIViewController {
				return viewController
			}
		}
		return nil
	}
	
	/// First responder.
	public var firstResponder: UIView? {
		guard !isFirstResponder else { return self }
		for subview in subviews where subview.isFirstResponder {
			return subview
		}
		return nil
	}
	
	/// Check if view is in RTL format.
	public var isRightToLeft: Bool {
		if #available(iOS 10.0, *, tvOS 10.0, *) {
			return effectiveUserInterfaceLayoutDirection == .rightToLeft
		} else {
			return false
		}
	}
}

// MARK: - Util
public extension UIView {
	///
	public func removeSubviews() {
		subviews.forEach { $0.removeFromSuperview() }
	}
	
	public func add(_ views: [UIView]) {
		views.forEach(addSubview)
	}
	
	public func add(_ subviews: UIView...) {
		subviews.forEach { addSubview($0) }
	}
	
	public func bringToFront() {
		superview?.bringSubviewToFront(self)
	}
	
	public func exclusiveTouchSubviews() {
		for view in subviews {
			if let button = view as? UIButton {
				button.isExclusiveTouch = true
			} else {
				view.exclusiveTouchSubviews()
			}
		}
	}

	/// 设置view的anchorPoint，同时保证view的frame不改变
	public func setAnchorPointFixedFrame(_ anchorPoint: CGPoint) {
		let oldOrigin = frame.origin
		layer.anchorPoint = anchorPoint
		let newOrign = frame.origin
		let transition = CGPoint(x: newOrign.x - oldOrigin.x, y: newOrign.y - oldOrigin.y)
		center = CGPoint(x: center.x - transition.x, y: center.y - transition.y)
	}
}

// MARK: Layer Extensions
extension UIView {
	/// Set some or all corners radiuses of view.
	///
	/// - Parameters:
	///   - corners: array of corners to change (example: [.bottomLeft, .topRight]).
	///   - radius: radius for selected corners.
	public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
		let maskPath = UIBezierPath(roundedRect: bounds,
									byRoundingCorners: corners,
									cornerRadii: CGSize(width: radius, height: radius))
		let shape = CAShapeLayer()
		shape.path = maskPath.cgPath
		layer.mask = shape
	}
	
	
	///  - Mask square/rectangle UIView with a circular/capsule cover, with a border of desired color and width around it
	public func roundView(borderColor color: UIColor? = nil, borderWidth width: CGFloat? = nil) {
		setCornerRadius(min(frame.size.height, frame.size.width) / 2)
		layer.borderWidth = width ?? 0
		layer.borderColor = color?.cgColor ?? UIColor.clear.cgColor
	}
	
	///
	public func setCornerRadius(_ radius: CGFloat) {
		layer.cornerRadius = radius
		layer.masksToBounds = true
	}
	
	///
	public func addShadow(offset: CGSize, radius: CGFloat, color: UIColor, opacity: Float, cornerRadius: CGFloat? = nil) {
		layer.shadowOffset = offset
		layer.shadowRadius = radius
		layer.shadowOpacity = opacity
		layer.shadowColor = color.cgColor
		if let r = cornerRadius {
			layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: r).cgPath
		}
	}
	
	///
	public func addBorder(width: CGFloat, color: UIColor) {
		layer.borderWidth = width
		layer.borderColor = color.cgColor
		layer.masksToBounds = true
	}
	
	///
	public func addBorderTop(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
	}
	
	///
	public func addBorderTopWithPadding(size: CGFloat, color: UIColor, padding: CGFloat) {
		addBorderUtility(x: padding, y: 0, width: frame.width - padding*2, height: size, color: color)
	}
	
	///
	public func addBorderBottom(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
	}
	
	///
	public func addBorderLeft(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
	}
	
	///
	public func addBorderRight(size: CGFloat, color: UIColor) {
		addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
	}
	
	///
	fileprivate func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
		let border = CALayer()
		border.backgroundColor = color.cgColor
		border.frame = CGRect(x: x, y: y, width: width, height: height)
		layer.addSublayer(border)
	}

	///
	public func drawCircle(fillColor: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) {
		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: w), cornerRadius: w/2)
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.fillColor = fillColor.cgColor
		shapeLayer.strokeColor = strokeColor.cgColor
		shapeLayer.lineWidth = strokeWidth
		layer.addSublayer(shapeLayer)
	}
	
	///
	public func drawStroke(width: CGFloat, color: UIColor) {
		let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: w), cornerRadius: w/2)
		let shapeLayer = CAShapeLayer ()
		shapeLayer.path = path.cgPath
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.strokeColor = color.cgColor
		shapeLayer.lineWidth = width
		layer.addSublayer(shapeLayer)
	}
}

// MARK: - Frame Layout
extension UIView {
	/// resizes this view so it fits the largest subview
	public func resizeToFitSubviews() {
		var width: CGFloat = 0
		var height: CGFloat = 0
		for someView in subviews {
			let aView = someView
			let newWidth = aView.x + aView.w
			let newHeight = aView.y + aView.h
			width = max(width, newWidth)
			height = max(height, newHeight)
		}
		frame = CGRect(x: x, y: y, width: width, height: height)
	}
	
	///
	public func resizeToFitWidth() {
		let currentHeight = h
		sizeToFit()
		h = currentHeight
	}
	
	///
	public func resizeToFitHeight() {
		let currentWidth = w
		sizeToFit()
		w = currentWidth
	}
	
	///
	public func leftOffset(_ offset: CGFloat) -> CGFloat {
		return left - offset
	}
	
	///
	public func rightOffset(_ offset: CGFloat) -> CGFloat {
		return right + offset
	}
	
	///
	public func topOffset(_ offset: CGFloat) -> CGFloat {
		return top - offset
	}
	
	///
	public func bottomOffset(_ offset: CGFloat) -> CGFloat {
		return bottom + offset
	}
	
	///
	public func alignRight(_ offset: CGFloat) -> CGFloat {
		return w - offset
	}
	
	///  Centers view in superview horizontally
	public func centerXInSuperView() {
		guard let parentView = superview else {
			return
		}
		
		x = parentView.w/2 - w/2
	}
	
	///  Centers view in superview vertically
	public func centerYInSuperView() {
		guard let parentView = superview else {
			return
		}
		
		y = parentView.h/2 - h/2
	}
	
	///  Centers view in superview horizontally & vertically
	public func centerInSuperView() {
		centerXInSuperView()
		centerYInSuperView()
	}
}

// MARK: - AutoLayout
/// 自己添加约束
public extension UIView {
	@discardableResult
	func layoutWidth(_ constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .width, constant: constant)
	}
	
	@discardableResult
	func layoutHeight(_ constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .height, constant: constant)
	}
	
	@discardableResult
	func layoutWidth(min constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .width, constant: constant, relatedBy: .greaterThanOrEqual)
	}
	
	@discardableResult
	func layoutHeight(min constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .height, constant: constant, relatedBy: .greaterThanOrEqual)
	}
	
	@discardableResult
	func layoutWidth(max constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .width, constant: constant, relatedBy: .lessThanOrEqual)
	}
	
	@discardableResult
	func layoutHeight(max constant: CGFloat) -> NSLayoutConstraint {
		return addConstraint(attribute: .height, constant: constant, relatedBy: .lessThanOrEqual)
	}
	
	@discardableResult
	func addConstraint(attribute: NSLayoutConstraint.Attribute, constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
		return UIView.addConstraint(on: self, attribute: attribute, relatedBy: relatedBy, multiplier: multiplier, constant: constant, priority: priority)
	}
}

/// 和父控件相关约束
public extension UIView {
	func layoutEqualParent(inset: UIEdgeInsets) {
		layoutTopParent(inset.top)
		layoutLeftParent(inset.left)
		layoutBottomParent(inset.bottom)
		layoutRightParent(inset.right)
	}
	
	func layoutEqualParent(_ offset: CGFloat = 0) {
		layoutTopParent(offset)
		layoutLeftParent(offset)
		layoutBottomParent(offset)
		layoutRightParent(offset)
	}
	
	func layoutCenterParent(_ offset: CGPoint = .zero) {
		layoutCenterHorizontal(offset.x)
		layoutCenterVertical(offset.y)
	}
	
	@discardableResult
	func layoutCenterHorizontal(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .centerX, constant: offset)
	}
	
	@discardableResult
	func layoutCenterVertical(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .centerY, constant: offset)
	}
	
	@discardableResult
	func layoutTopParent(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .top, constant: offset)
	}
	
	@discardableResult
	func layoutLeftParent(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .left, constant: offset)
	}
	
	@discardableResult
	func layoutBottomParent(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .bottom, constant: -offset)
	}
	
	@discardableResult
	func layoutRightParent(_ offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWithParent(attribute: .right, constant: -offset)
	}
	
	@discardableResult
	func addConstraintWithParent(attribute: NSLayoutConstraint.Attribute, constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint? {
		guard let superview = superview else {
			return nil
		}
		
		return UIView.addConstraint(on: superview, item: self, attribute: attribute, relatedBy: relatedBy, toItem: superview, attribute: attribute, multiplier: multiplier, constant: constant, priority: priority)
	}
}

/// 和兄弟控件相关约束
public extension UIView {
	@discardableResult
	func layoutTop(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .top, attribute: .top, constant: offset)
	}
	
	@discardableResult
	func layoutLeft(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .left, attribute: .left, constant: offset)
	}
	
	@discardableResult
	func layoutBottom(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .bottom, attribute: .bottom,  constant: offset)
	}
	
	@discardableResult
	func layoutRight(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .right, attribute: .right, constant: offset)
	}
	
	@discardableResult
	func layoutHorizontal(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .left, attribute: .right, constant: offset)
	}
	
	@discardableResult
	func layoutVertical(view: UIView, offset: CGFloat = 0) -> NSLayoutConstraint? {
		return addConstraintWith(view: view, attribute: .top, attribute: .bottom, constant: offset)
	}
	
	@discardableResult
	func addConstraintWith(view: UIView, attribute attribute1: NSLayoutConstraint.Attribute, attribute attribute2: NSLayoutConstraint.Attribute, constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, multiplier: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint? {
		guard let superview = superview else {
			return nil
		}
		
		return UIView.addConstraint(on: superview, item: self, attribute: attribute1, relatedBy: relatedBy, toItem: view, attribute: attribute2, multiplier: multiplier, constant: constant, priority: priority)
	}
}

public extension UIView {
	/// 给target添加约束
	@discardableResult
	class func addConstraint(on target: UIView, attribute: NSLayoutConstraint.Attribute, relatedBy: NSLayoutConstraint.Relation, multiplier: CGFloat, constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
		return UIView.addConstraint(on: target, item: target, attribute: attribute, relatedBy: relatedBy, toItem: nil, attribute: .notAnAttribute, multiplier: multiplier, constant: constant, priority: priority)
	}
	
	/**
	0、translatesAutoresizingMaskIntoConstraints：
	The translatesAutoresizingMaskIntoConstraints property is set to NO, so our constraints will not conflict with the old “springs and struts” method.
	
	1、NSLayoutConstraint类，是IOS6引入的，字面意思是“约束”、“限制”的意思，实现相对布局，就依靠这个类了；
	
	2、怎么理解这个方法调用：
	NSLayoutConstraint *constraint = [NSLayoutConstraint
	constraintWithItem:firstButton        firstButton是我们实例化的按钮
	attribute:NSLayoutAttributeLeading    firstButton的左边
	relatedBy:NSLayoutRelationEqual       firstButton的左边与self.view的左边的相对关系
	toItem:self.view                      指定firstButton的相对的对象是self.view
	attribute:NSLayoutAttributeLeading    相对与self.view的左边（NSLayoutAttributeLeading是左边的意思）
	multiplier:1.0f                                       （后文介绍）
	constant:20.f];                       firstButton左边相对self.view左边，向右边偏移了20.0f (根据IOS坐标系，向右和向下是正数)
	[self.view addConstraint:constraint]; 将这个约束添加到self.view上
	
	附视图的属性和关系的值:
	typedef NS_ENUM(NSInteger, NSLayoutRelation) {
	NSLayoutRelationLessThanOrEqual = -1,          //小于等于
	NSLayoutRelationEqual = 0,                     //等于
	NSLayoutRelationGreaterThanOrEqual = 1,        //大于等于
	};
	
	typedef NS_ENUM(NSInteger, NSLayoutAttribute) {
	NSLayoutAttributeLeft = 1,                     //左侧
	NSLayoutAttributeRight,                        //右侧
	NSLayoutAttributeTop,                          //上方
	NSLayoutAttributeBottom,                       //下方
	NSLayoutAttributeLeading,                      //首部
	NSLayoutAttributeTrailing,                     //尾部
	NSLayoutAttributeWidth,                        //宽度
	NSLayoutAttributeHeight,                       //高度
	NSLayoutAttributeCenterX,                      //X轴中心
	NSLayoutAttributeCenterY,                      //Y轴中心
	NSLayoutAttributeBaseline,                     //文本底标线
	
	NSLayoutAttributeNotAnAttribute = 0            //没有属性
	};
	
	NSLayoutAttributeLeft/NSLayoutAttributeRight 和 NSLayoutAttributeLeading/NSLayoutAttributeTrailing的区别是left/right永远是指左右，
	而leading/trailing在某些从右至左习惯的地区会变成，leading是右边，trailing是左边。(大概是⊙﹏⊙b)
	*/
	@discardableResult
	class func addConstraint(on target: UIView, item: Any, attribute attribute1: NSLayoutConstraint.Attribute, relatedBy: NSLayoutConstraint.Relation, toItem: Any?, attribute attribute2: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant: CGFloat, priority: UILayoutPriority) -> NSLayoutConstraint {
		//		target.translatesAutoresizingMaskIntoConstraints = false
		//		(toItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
		(item as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
		let constraint = NSLayoutConstraint(item: item, attribute: attribute1, relatedBy: relatedBy, toItem: toItem, attribute: attribute2, multiplier: multiplier, constant: constant)
		constraint.priority = priority
		target.addConstraint(constraint)
		return constraint
	}
}

// MARK: - Frame Sugar
public extension UIView {
	///
	public var x: CGFloat {
		get {
			return frame.origin.x
		} set(value) {
			frame = CGRect(x: value, y: y, width: w, height: h)
		}
	}
	
	///
	public var y: CGFloat {
		get {
			return frame.origin.y
		} set(value) {
			frame = CGRect(x: x, y: value, width: w, height: h)
		}
	}
	
	///
	public var w: CGFloat {
		get {
			return frame.size.width
		} set(value) {
			frame = CGRect(x: x, y: y, width: value, height: h)
		}
	}
	
	///
	public var h: CGFloat {
		get {
			return frame.size.height
		} set(value) {
			frame = CGRect(x: x, y: y, width: w, height: value)
		}
	}
	
	///
	public var width: CGFloat {
		get {
			return frame.size.width
		} set(value) {
			frame = CGRect(x: x, y: y, width: value, height: h)
		}
	}
	
	///
	public var height: CGFloat {
		get {
			return frame.size.height
		} set(value) {
			frame = CGRect(x: x, y: y, width: w, height: value)
		}
	}
	
	///
	public var left: CGFloat {
		get {
			return x
		} set(value) {
			x = value
		}
	}
	
	///
	public var right: CGFloat {
		get {
			return x + w
		} set(value) {
			x = value - w
		}
	}
	
	///
	public var top: CGFloat {
		get {
			return y
		} set(value) {
			y = value
		}
	}
	
	///
	public var bottom: CGFloat {
		get {
			return y + h
		} set(value) {
			y = value - h
		}
	}
	
	///
	public var origin: CGPoint {
		get {
			return frame.origin
		} set(value) {
			frame = CGRect(origin: value, size: frame.size)
		}
	}
	
	///
	public var centerX: CGFloat {
		get {
			return center.x
		} set(value) {
			center.x = value
		}
	}
	
	///
	public var centerY: CGFloat {
		get {
			return center.y
		} set(value) {
			center.y = value
		}
	}
	
	///
	public var size: CGSize {
		get {
			return frame.size
		} set(value) {
			frame = CGRect(origin: frame.origin, size: value)
		}
	}
}

// MARK: - IBInspectable
public extension UIView {
	/// Border color of view; also inspectable from Storyboard.
	@IBInspectable public var borderColor: UIColor? {
		get {
			return layer.borderColor.flatMap { UIColor(cgColor: $0) }
		}
		set {
			layer.borderColor = newValue.flatMap { $0.cgColor }
		}
	}
	
	/// Border width of view; also inspectable from Storyboard.
	@IBInspectable public var borderWidth: CGFloat {
		get {
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
		}
	}
	
	/// Corner radius of view; also inspectable from Storyboard.
	@IBInspectable public var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.masksToBounds = true
			layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
		}
	}
	
	/// Shadow color of view; also inspectable from Storyboard.
	@IBInspectable public var shadowColor: UIColor? {
		get {
			guard let color = layer.shadowColor else { return nil }
			return UIColor(cgColor: color)
		}
		set {
			layer.shadowColor = newValue?.cgColor
		}
	}
	
	/// Shadow offset of view; also inspectable from Storyboard.
	@IBInspectable public var shadowOffset: CGSize {
		get {
			return layer.shadowOffset
		}
		set {
			layer.shadowOffset = newValue
		}
	}
	
	/// Shadow opacity of view; also inspectable from Storyboard.
	@IBInspectable public var shadowOpacity: Float {
		get {
			return layer.shadowOpacity
		}
		set {
			layer.shadowOpacity = newValue
		}
	}
	
	/// Shadow radius of view; also inspectable from Storyboard.
	@IBInspectable public var shadowRadius: CGFloat {
		get {
			return layer.shadowRadius
		}
		set {
			layer.shadowRadius = newValue
		}
	}
}













