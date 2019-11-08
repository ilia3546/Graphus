//
//  QueryBuilder.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 10/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query builder
public class QueryBuilder {
    
    /// GraphQL type fields
    public var fields = [Field]()
    
    /// Query
    public func query() -> GraphQueryContainer {
        return GraphQueryContainer(self)
    }
    
    public init() {}
    
}

