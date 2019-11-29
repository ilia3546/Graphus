//
//  KeyedQuery.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 29.11.2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class KeyedQuery<Key: CodingKey>: Query {
    
    public init(_ name: Key, arguments: Arguments = [:], fields: [Field] = []) {
        super.init(name.stringValue, arguments: arguments, fields: fields)
    }
    
    public init(_ alias: Key, name: String, arguments: Arguments = [:], fields: [Field] = []) {
        super.init(name, alias: alias.stringValue, arguments: arguments, fields: fields)
    }
    
    public convenience init(_ name: Key, arguments: Arguments = [:], model: Queryable.Type, context: QueryBuilderContext? = nil) {
        self.init(name, arguments: arguments, fields: model.fields(with: context))
    }
    
    public convenience init(_ alias: Key, name: String, arguments: Arguments = [:], model: Queryable.Type, context: QueryBuilderContext? = nil) {
        self.init(alias, name: name, arguments: arguments, fields: model.fields(with: context))
    }
    
}
