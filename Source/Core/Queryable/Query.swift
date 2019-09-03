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
    
    public  enum Mode: String {
        case query, mutation
    }
    
    public var mode: Mode = .query
    public var name: String
    public var fields: [Field]
    public var arguments = Arguments()
    
    public init(_ name: String, arguments: Arguments? = nil, fields: [Field]) {
        self.name = name
        self.fields = fields
        self.arguments = arguments ?? [:]
    }
    
    public init(_ name: String, arguments: Arguments? = nil, model: Queryable.Type, context: QueryBuilderContext? = nil) {
        self.init(name, arguments: arguments, fields: model.fields(with: context))
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
        res.append(self.name)
        if !self.arguments.isEmpty {
            let argumentsStr = self.arguments
                .map({ "\($0): \($1.argumentValue)" })
                .joined(separator: ",")
            res.append("(\(argumentsStr))")
        }
        
        res.append("{\(self.fields.map({ $0.fieldString }).joined(separator: ","))}")
        return res.joined(separator: "")
    }
    
    internal var uploads: [Upload] {
        return self.uploads(in: self.arguments)
    }
    
    private func uploads(in argumentsArr: Arguments) -> [Upload] {
        var result: [Upload] = []
        for (_, value) in argumentsArr {
            if let value = value as? [Upload] {
                result.append(contentsOf: value)
            }else if let value = value as? Upload {
                result.append(value)
            }else if let value = value as? Mutable {
                result.append(contentsOf: self.uploads(in: value.arguments))
            }else if let value = value as? Arguments {
                result.append(contentsOf: self.uploads(in: value))
            }
        }
        return result
    }
    
    public func build() -> String {
        var result = self.mode.rawValue
        let uploads = self.uploads
        
        if !uploads.isEmpty {
            let uploadsVariables = uploads.map({ upload in
                var res = upload.argumentValue + ": Upload"
                if !upload.nullable { res += "!" }
                return res
            }).joined(separator: ", ")
            result += " (\(uploadsVariables)) "
        }
        
        result += "{\(self.fieldString)}"
        return result
    }
    
}
