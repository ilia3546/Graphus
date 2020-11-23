//
//  QueryKeyedContainer.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query
public class QueryKeyedContainer<Key: CodingKey> {
    
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
    
    public func addField(_ keyedField: Key){
        self.addField(keyedField.stringValue)
    }
    
    public func addFields(_ keyedFields: [Key]) {
        self.addFields(keyedFields.map({ $0.stringValue }))
    }
   
    public func addField(_ keyedQuery: KeyedQuery<Key>) {
        self.addField(keyedQuery as Field)
    }
    
    public func on(_ typeName: String, keyedClosure: @escaping (QueryKeyedContainer) -> Void) {
        let builder = QueryBuilder()
        keyedClosure(builder.query(keyedBy: Key.self))
        self.builder.fields.append(OnQuery(typeName: typeName, fields: builder.fields))
    }
    
    public func on(_ typeName: String, model: Queryable.Type, context: QueryBuilderContext? = nil) {
        let builder = QueryBuilder()
        model.buildQuery(with: builder, context: context)
        self.builder.fields.append(OnQuery(typeName: typeName, fields: builder.fields))
    }
    
}
