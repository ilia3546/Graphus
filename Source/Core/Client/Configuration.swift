//
//  Configuration.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 21.05.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation
import Alamofire

public struct GraphusConfiguration {
    public static var `default` = GraphusConfiguration()
    
    public var eventMonitors: [EventMonitor] = []
    public var serverTrustManager: ServerTrustManager?
    public var cachedResponseHandler: CachedResponseHandler?
    public var redirectHandler: RedirectHandler?
    public var interceptor: RequestInterceptor?
    public var requestModifier: Session.RequestModifier?
    public var requestTimeout: TimeInterval = 60
    public var httpHeaders: HTTPHeaders?
    public var rootResponseKey: String = "data"
    public var rootErrorsKey: String? = "errors"
    
}
