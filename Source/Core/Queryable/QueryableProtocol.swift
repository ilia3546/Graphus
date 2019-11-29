//
//  QueryBuildable.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 11/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol QueryBuilderContext {}

/// GraphQL query build model protocol
public protocol Queryable {
    /// Query building
    static func buildQuery(with builder: QueryBuilder, context: QueryBuilderContext?)
}



extension Queryable {
    static func fields(with context: QueryBuilderContext?) -> [Field] {
        let builder = QueryBuilder()
        buildQuery(with: builder, context: context)
        return builder.fields
    }
}

extension Array: QueryBuilderContext where Element: Field {}

extension Array: Queryable where Element: Queryable {
    
    public static func buildQuery(with builder: QueryBuilder, context: QueryBuilderContext?) {
        self.Element.buildQuery(with: builder, context: context)
    }
    
}
