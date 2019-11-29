//
//  GraphClient.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class GraphusClient {
    
    public let configuration: URLSessionConfiguration
    public let url: URL
    internal lazy var session: URLSession = {
        return URLSession(configuration: self.configuration)
    }()
    
    /// Debug parameter
    public enum DebugParam {
        
        /// Log request when it's sended
        ///
        /// Example: `[Graphus] send request "createBook"`
        case logSendedRequests
        
        /// Log request amount time and code when it's recived
        ///
        /// Example: `[Graphus] response for method "createBook", 200, 1.197s`
        case logRequestAmountTime
        
        /// Print sendable queries into console
        ///
        /// Example: `[Graphus] request query "mutation {createBook(title: "Francis Scott Key Fitzgerald",author: "The Great Gatsby"){id,title,author,isbn,url}}"`
        case printSendableQueries
    }
    
    /// Root response key
    ///
    /// It is used for response mapping
    public var rootResponseKey = "data"
    
    /// Root key for mapping errors
    ///
    /// The default value is "errors"
    public var rootErrorsKey: String? = "errors"
    
    /// Debug params
    ///
    /// You can set up debugging params
    public var debugParams: [DebugParam] = []
    
    /// Create graphus client
    public init(url: URL, configuration: URLSessionConfiguration){
        self.configuration = configuration
        self.url = url
    }
    
    /// Crate query request
    public func request(_ mode: GraphusRequest.Mode = .query, query: Query) -> GraphusRequest {
        return .init(mode, query: query, client: self)
    }

    
}


