//
//  GraphQueryKeyedContainer.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation


/// GraphQL query
public class GraphQueryKeyedContainer<Key: CodingKey>: GraphQueryContainer{
    
    /// Add simple graphQL field
    public func addField(_ key: Key){
        addField(key.stringValue)
    }
    
    public func addFields(_ childFields: [Field], with args: Arguments? = nil, forKey key: Key) {
        addFields(childFields, with: args, forKey: key.stringValue)
    }
    
    /// Add child query
    public func addChild(_ child: Queryable.Type, context: QueryBuilderContext? = nil, with args: Arguments? = nil, forKey key: Key){
        addChild(child, context: context, with: args, forKey: key.stringValue)
    }
    
}
