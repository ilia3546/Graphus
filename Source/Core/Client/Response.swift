//
//  Response.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public struct GraphusResponse<T> {
    
    public var data: T?
    public var errors: [GraphQLError] = []
    
    init(data: T?) {
        self.data = data
    }
    
    public var hasErrors: Bool {
        return !self.errors.isEmpty
    }

}


