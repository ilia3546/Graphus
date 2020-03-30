//
//  Logger.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 30.03.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol GraphusLoggerProtocol {
    func querySended(mode: GraphusRequest.Mode, name: String, queryString: String)
    func responseRecived(name: String, statusCode: Int, duration: TimeInterval)
}

internal class GraphusLogger: GraphusLoggerProtocol {
    
    func querySended(mode: GraphusRequest.Mode, name: String, queryString: String) {
        NSLog("[Graphus] Query \"%@\" sended: %@ %@", name, mode.rawValue, queryString)
    }
    
    func responseRecived(name: String, statusCode: Int, duration: TimeInterval) {
        NSLog("[Graphus] Response \"%@\" recived. Code: %d. Duration: %.3f", name, statusCode, duration)
    }
    
}
