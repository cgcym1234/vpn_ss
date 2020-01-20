//
//  UserDefaults+YYLib.swift
//  SwiftProject
//
//  Created by yangyuan on 2018/1/30.
//  Copyright © 2018年 huan. All rights reserved.
//

import Foundation

public extension UserDefaults {
	/// SwifterSwift: get object from UserDefaults by using subscript
	///
	/// - Parameter key: key in the current user's defaults database.
	public subscript(key: String) -> Any? {
		get {
			return object(forKey: key)
		}
		set {
			set(newValue, forKey: key)
		}
	}
}

public extension UserDefaults {
	/// SwifterSwift: Retrieves a Codable object from UserDefaults.
	///
	/// - Parameters:
	///   - type: Class that conforms to the Codable protocol.
	///   - key: Identifier of the object.
	///   - decoder: Custom JSONDecoder instance. Defaults to `JSONDecoder()`.
	/// - Returns: Codable object for key (if exists).
	public func object<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
		guard let data = value(forKey: key) as? Data else { return nil }
		return try? JSONDecoder().decode(type.self, from: data)
	}
	
	/// SwifterSwift: Allows storing of Codable objects to UserDefaults.
	///
	/// - Parameters:
	///   - object: Codable object to store.
	///   - key: Identifier of the object.
	///   - encoder: Custom JSONEncoder instance. Defaults to `JSONEncoder()`.
	public func set<T: Codable>(object: T?, forKey key: String) {
		var data: Data?
        if let obj = object {
            data = try? JSONEncoder().encode(obj)
        }
		set(data, forKey: key)
	}
}

