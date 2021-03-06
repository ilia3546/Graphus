//
//  GraphQuery.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query
public class QueryContainer {
    
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
    
    public func on(_ typeName: String, closure: @escaping (QueryContainer) -> Void) {
        let builder = QueryBuilder()
        closure(builder.query())
        self.builder.fields.append(OnQuery(typeName: typeName, fields: builder.fields))
    }
    
    public func on(_ typeName: String, model: Queryable.Type, context: QueryBuilderContext? = nil) {
        let builder = QueryBuilder()
        model.buildQuery(with: builder, context: context)
        self.builder.fields.append(OnQuery(typeName: typeName, fields: builder.fields))
    }

}

