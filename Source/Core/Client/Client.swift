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
    
    /// Root response key
    ///
    /// It is used for response mapping
    public var rootResponseKey = "data"
    
    /// Root key for mapping errors
    ///
    /// The default value is "errors"
    public var rootErrorsKey: String? = "errors"
    
    /// Logger
    ///
    /// You can set up debugging params
    public var logger: GraphusLoggerProtocol
    
    /// Create graphus client
    public init(url: URL, configuration: URLSessionConfiguration){
        self.configuration = configuration
        self.url = url
        self.logger = GraphusLogger()
    }
    
    /// Crate query request
    public func request(_ mode: GraphusRequest.Mode = .query, query: Query) -> GraphusRequest {
        return .init(mode, query: query, client: self)
    }

    
}
