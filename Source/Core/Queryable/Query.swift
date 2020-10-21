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

extension WritableKeyPath: Field where Root: Reflectable, Value: ReflectionDecodable {
    public var fieldString: String {
        if let property = try? Root.reflectProperty(forKey: self), let rootProp = property.path.first {
            if property.path.count > 1 {
                return Query(rootProp, fields: Array(property.path.dropFirst())).fieldString
            } else {
                return rootProp
            }
        }
        return ""
    }
}

public class Query: Field {
    
    public var name: String?
    public var alias: String?
    public var fields: [Field]
    public var arguments = Arguments()
    
    private init(fields: [Field] = []) {
        self.fields = fields
    }
    
    public static func unnamed(fields: [Field]) -> Query {
        return Query(fields: fields)
    }
    
    public static func unnamed(model: Queryable.Type, context: QueryBuilderContext? = nil) -> Query {
        return Query(fields: model.fields(with: context))
    }
    
    public init(_ name: String, alias: String? = nil, arguments: Arguments = [:], fields: [Field]) {
        self.name = name
        self.alias = alias
        self.fields = fields
        self.arguments = arguments
    }
    
    public convenience init<T: Reflectable, Z: ReflectionDecodable>(_ name: String, alias: String? = nil, arguments: Arguments = [:], on reflectableModel: T.Type, fields: [WritableKeyPath<T, Z>]) {
        self.init(name, alias: alias, arguments: arguments, fields: fields)
    }
    
    public convenience init(_ name: String, alias: String? = nil, arguments: Arguments = [:], model: Queryable.Type, context: QueryBuilderContext? = nil) {
        self.init(name, alias: alias, arguments: arguments, fields: model.fields(with: context))
    }
    
    public func appendArguments(_ newArgs: Arguments?){
        if let newArgs = newArgs {
            self.arguments.merge(newArgs, uniquingKeysWith: merge)
        }
    }
    
    private func merge(_ a: ArgumentValue, _ b: ArgumentValue) -> ArgumentValue {
        
        if let a = a as? Arguments, let b = b as? Arguments {
            return a.merging(b, uniquingKeysWith: merge)
        }else{ return a }
    }
    
    public var fieldString: String {
        
        var res = [String]()
        
        guard let name = self.name else {
            return self.fields.map({ $0.fieldString }).joined(separator: ",")
        }
        
        if let alias = self.alias {
            res.append("\(alias): \(name)")
        } else {
            res.append(name)
        }
        if !self.arguments.isEmpty {
            let argumentsStr = self.arguments
                .map({ "\($0): \($1.argumentValue)" })
                .joined(separator: ",")
            res.append("(\(argumentsStr))")
        }
        if !self.fields.isEmpty {
            res.append("{\(self.fields.map({ $0.fieldString }).joined(separator: ","))}")
        }
        
        return res.joined()
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
        var result = ""
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
