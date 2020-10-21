//
//  QueryBuilder + Coding.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

extension QueryBuilder {
    /// Query
    public func query<Key>(keyedBy type: Key.Type) -> QueryKeyedContainer<Key> where Key : CodingKey {
        return QueryKeyedContainer<Key>(self)
    }
    
}
