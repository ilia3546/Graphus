//
//  GraphQueryKeyedContainer.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

/// GraphQL query
public class GraphQueryKeyedContainer<Key: CodingKey>: GraphQueryContainer{
    
    public func addField(_ keyedField: Key){
        super.addField(keyedField.stringValue)
    }
    
    public func addFields(_ keyedFields: [Key]){
        super.addFields(keyedFields.map({ $0.stringValue }))
    }
    
    public func addField(_ keyedQuery: KeyedQuery<Key>){
        super.addField(keyedQuery)
    }
    
}
