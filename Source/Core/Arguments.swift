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

extension String: ArgumentValue {
    public var argumentValue: String {
        var res: String = ""
        for char in self {
            switch char {
            case "\\": res += "\\\\"
            case "\n": res += "\\n"
            case "\"": res += "\\\""
            default: res += "\(char)"
            }
        }
        return String(format: "\"%@\"", res)
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
