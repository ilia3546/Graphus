//
//  GraphQLError.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 12/08/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public struct GraphQLError: Error {
    
    public struct Location {
        public var line: Int
        public var column: Int
    }
    
    public var message: String
    public var locations: [Location]?
    public var path: [String]?
    public var extensions: Any?
    
    init?(_ json: Any) {
        guard let json = json as? [String: Any],
            let message = json["message"] as? String else {
            return nil
        }
        
        self.message = message
        if let locations = json["locations"] as? [[String: Int]]{
            self.locations = locations.compactMap({
                if let line = $0["line"], let column = $0["column"] {
                    return Location(line: line, column: column)
                }
                return nil
            })
        }
        
        self.path = json["path"] as? [String]
        self.extensions = json["extensions"]
        
    }
    
}
