//
//  FieldsKeyedContainer.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public class FieldsKeyedContainer<Key: CodingKey>: FieldsContainer {
    
    public func addField(_ keyedField: Key){
        super.addField(keyedField.stringValue)
    }
    
    public func addFields(_ keyedFields: [Key]){
        super.addFields(keyedFields.map({ $0.stringValue }))
    }
    
}
