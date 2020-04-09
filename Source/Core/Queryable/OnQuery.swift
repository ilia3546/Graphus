//
//  OnQuery.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 09.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

internal class OnQuery: Field {
    
    internal var typeName: String
    internal var fields: [Field]
    
    internal init(typeName: String, fields: [Field]) {
        self.typeName = typeName
        self.fields = fields
    }
    
    internal var fieldString: String {
        var res = ["... on \(self.typeName)"]
        res.append("{\(self.fields.map({ $0.fieldString }).joined(separator: ","))}")
        return res.joined()
    }
    
}
