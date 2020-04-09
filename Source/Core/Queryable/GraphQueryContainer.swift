//
//  GraphQuery.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query
public class GraphQueryContainer {
    
    internal var builder: QueryBuilder
    
    internal init(_ builder: QueryBuilder){
        self.builder = builder
    }
    
    public func addField(_ field: Field){
        self.builder.fields.append(field)
    }
    
    public func addFields(_ fields: [Field]){
        self.builder.fields.append(contentsOf: fields)
    }
    
    public func on(_ typeName: String, closure: @escaping (GraphQueryContainer) -> Void) {
        let builder = QueryBuilder()
        closure(builder.query())
        self.builder.fields.append(OnQuery(typeName: typeName, fields: builder.fields))
    }

}

