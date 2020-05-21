//
//  GraphClient.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation
import Alamofire

public class GraphusClient: SessionDelegate {
    
    internal let session: Session

    public let configuration: GraphusConfiguration
    public let url: URLConvertible
    public var logger: GraphusLoggerProtocol = GraphusLogger()
    
    /// Create graphus client
    public init(url: URLConvertible, configuration: GraphusConfiguration = .default){
        self.url = url
        self.configuration = configuration
        
        self.session = Session(configuration: URLSessionConfiguration.af.default,
                               delegate: GraphusSessionDelegate(),
                               rootQueue: DispatchQueue(label: "com.graphus.session.rootQueue"),
                               startRequestsImmediately: true,
                               requestQueue: DispatchQueue(label: "com.graphus.session.requestQueue"),
                               serializationQueue: DispatchQueue(label: "com.graphus.session.serializationQueue"),
                               interceptor: nil,//configuration.interceptor,
                               serverTrustManager: configuration.serverTrustManager,
                               redirectHandler: configuration.redirectHandler,
                               cachedResponseHandler: configuration.cachedResponseHandler,
                               eventMonitors: configuration.eventMonitors)
    }
    
    /// Crate query request
    public func request(_ mode: GraphusRequest.Mode = .query, query: Query) -> GraphusRequest {
        return .init(mode, query: query, clientReference: self)
    }
    
}

internal class GraphusSessionDelegate: SessionDelegate {
    
}
