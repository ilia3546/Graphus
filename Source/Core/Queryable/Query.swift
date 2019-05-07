//
//  GraphField.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Field {
    var fieldString: String { get }
}

extension String: Field {
    public var fieldString: String {
        return self
    }
}

public struct Query: Field {
    
    public var name: String
    public var fields: [Field]
    public var arguments = Arguments()
    
    public init(_ name: String, arguments: Arguments? = nil, fields: [Field]) {
        self.name = name
        self.fields = fields
        self.arguments = arguments ?? [:]
    }
    
    public init(_ name: String, arguments: Arguments? = nil, model: Queryable.Type) {
        self.init(name, arguments: arguments, fields: model.fields)
    }
    
    public mutating func appendArguments(_ newArgs: Arguments?){
        if let newArgs = newArgs {
            arguments.merge(newArgs, uniquingKeysWith: merge)
        }
    }
    
    private func merge(_ a: ArgumentValue, _ b: ArgumentValue) -> ArgumentValue {
        
        if let a = a as? Arguments, let b = b as? Arguments {
            return a.merging(b, uniquingKeysWith: merge)
        }else{ return a }
    }
    
    public var fieldString: String {
        var res = [String]()
        res.append(name)
        if arguments.count > 0 {
            res.append("(\(arguments.map({ "\($0): \($1.argumentValue)" }).joined(separator: ",")))")
        }
        res.append("{\(fields.map({ $0.fieldString }).joined(separator: ","))}")
        return res.joined(separator: "")
    }
    
    internal func build() -> String {
        return "{\(fieldString)}"
    }
    
}
