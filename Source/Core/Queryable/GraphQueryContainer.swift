//
//  GraphQuery.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation


/// GraphQL query
public class GraphQueryContainer{
    
    /// GraphQL query builder
    internal var builder: QueryBuilder
    
    internal init(_ builder: QueryBuilder){
        self.builder = builder
    }
    
    /// Add simple graphQL field
    public func addField(_ key: String){
        builder.fields.append(key)
    }
    
    public func addFields(_ fields: [Field], with args: Arguments? = nil, forKey key: String) {
        builder.fields.append(Query(key, arguments: args, fields: fields))
    }
    
    /// Add child query
    public func addChild(_ child: Queryable.Type, context: QueryBuilderContext? = nil, with args: Arguments? = nil, forKey key: String){
        builder.fields.append(Query(key, arguments: args, model: child, context: context))
    }
    
    public func addUnkeyedFields(_ fields: [Field]) {
        builder.fields.append(contentsOf: fields)
    }
    
}

