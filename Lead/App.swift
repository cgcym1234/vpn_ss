//
//  App.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import Foundation

struct App {
    static func randomNumString() -> String {
        let num = arc4random() % 1000000
        return String(format: "%.6d", num)
    }
    
    static let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyyMMddHHmmssSSS"
    }
    
    static var timestampId: String {
        return dateFormatter.string(from: Date()) + randomNumString()
    }
}
