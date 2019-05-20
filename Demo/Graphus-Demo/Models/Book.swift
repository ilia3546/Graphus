//
//  Book.swift
//  Graphus-Demo
//
//  Created by Ilya Kharlamov on 07/05/2019.
//  Copyright © 2019 Ilya Kharlamov. All rights reserved.
//

import Foundation
import Graphus

struct Book: Decodable, Queryable {
    
    var title: String
    var isbn: String
    
    static func buildQuery(with builder: QueryBuilder, context: QueryBuilderContext?) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.title)
        query.addField(.isbn)
    }
    
}
