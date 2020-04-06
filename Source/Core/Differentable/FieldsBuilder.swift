//
//  FieldsBuilder.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public class FieldsBuilder {
    
    /// GraphQL type fields
    public var fields = [String]()
    
    /// Query
    public func container() -> FieldsContainer {
        return FieldsContainer(self)
    }
    
    public init() {}
    
}
