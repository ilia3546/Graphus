//
//  QueryBuildable.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 11/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query build model protocol
public protocol Queryable {
    /// Query building
    static func buildQuery(with builder: QueryBuilder)
}

extension Queryable {
    static var fields: [Field] {
        let builder = QueryBuilder()
        buildQuery(with: builder)
        return builder.fields
    }
}
