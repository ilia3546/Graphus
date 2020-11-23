//
//  AbstractContainer.swift
//  Pods
//
//  Created by Ilya Kharlamov on 23.11.2020.
//

import Foundation

extension QueryBuilder {
    public func abstractQuery<Type>(typedBy: Type.Type) -> QueryAbstractContainer<Type> where Type : AbstractType {
        return QueryAbstractContainer<Type>(self)
    }
}

public class QueryAbstractContainer<Type: AbstractType> {
    
    internal var builder: QueryBuilder
    
    internal init(_ builder: QueryBuilder){
        self.builder = builder
        self.builder.fields.append("__typename")
    }
    
    public func addModel(_ model: Queryable.Type, for type: Type, with context: QueryBuilderContext? = nil) {
        let builder = QueryBuilder()
        model.buildQuery(with: builder, context: context)
    }
    
}
