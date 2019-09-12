//
//  MutationValue.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public typealias Arguments = [String: ArgumentValue]

public protocol ArgumentValue {
    var argumentValue: String { get }
}

extension Dictionary: ArgumentValue where Key == String, Value == ArgumentValue {
    public var argumentValue: String {
        return "{\(map({ "\($0): \($1.argumentValue)" }).joined(separator: ","))}"
    }
}

extension NSNull: ArgumentValue {
    public var argumentValue: String {
        return "null"
    }
}

extension String: ArgumentValue {
    public var argumentValue: String {
        return String(format: "\"%@\"", self.escaped)
    }
}

extension Bool: ArgumentValue {
    public var argumentValue: String {
        return String(self)
    }
}

extension Int: ArgumentValue {
    public var argumentValue: String {
        return "\(self)"
    }
}

extension Double: ArgumentValue {
    public var argumentValue: String {
        return "\(self)"
    }
}

extension Float: ArgumentValue {
    public var argumentValue: String {
        return "\(self)"
    }
}


extension Array: ArgumentValue where Element: ArgumentValue {
    public var argumentValue: String {
        return "[\(self.map({ $0.argumentValue }).joined(separator: ","))]"
    }
}


extension String {
    internal var escaped: String {
        var res: String = ""
        for char in self {
            switch char {
            case "\\": res += "\\\\"
            case "\n": res += "\\n"
            case "\r": res += "\\r"
            case "\r\n": res += "\\r\\n"
            case "\"": res += "\\\""
            default: res += "\(char)"
            }
        }
        return res
    }
}
