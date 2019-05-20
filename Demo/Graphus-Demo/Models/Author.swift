//
//  Author.swift
//  Graphus-Demo
//
//  Created by Ilya Kharlamov on 07/05/2019.
//  Copyright © 2019 Ilya Kharlamov. All rights reserved.
//

import Foundation
import Graphus

struct Author: Decodable, Queryable {
    
    struct Context: QueryBuilderContext {
        var incudeBooks: Bool
    }
    
    var firstName: String
    var secondName: String
    var books: [Book]?
    
    static func buildQuery(with builder: QueryBuilder, context: QueryBuilderContext?) {
        let query = builder.query(keyedBy: CodingKeys.self)
        query.addField(.firstName)
        query.addField(.secondName)
        if let context = context as? Context, context.incudeBooks {
            query.addChild(Book.self, forKey: .books)
        }
    }
    
}
