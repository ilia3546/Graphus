//
//  FieldsContainer.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public class FieldsContainer {
    
    internal var builder: FieldsBuilder
    
    internal init(_ builder: FieldsBuilder){
        self.builder = builder
    }
    
    public func addField(_ field: String){
        self.builder.fields.append(field)
    }
    
    public func addFields(_ fields: [String]){
        self.builder.fields.append(contentsOf: fields)
    }

}
