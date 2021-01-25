//
//  Request.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation
import Alamofire

public class GraphusRequest {

    public private(set) var mode: Mode
    public private(set) var query: Query
    
    internal var clientReference: GraphusClient
    internal let request: Alamofire.DataRequest
    
    init(_ mode: Mode = .query, query: Query, clientReference: GraphusClient) {
        self.clientReference = clientReference
        self.query = query
        self.mode = mode
                
        var httpHeaders = clientReference.configuration.httpHeaders ?? []
        if !httpHeaders.contains(where: { $0.name.lowercased() == "user-agent" }),
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            httpHeaders.add(name: "User-Agent", value: "Graphus /\(version)")
        }
        
        var request = clientReference.session.upload(multipartFormData: { multipartFormData in
            
            let queryStr = mode.rawValue + query.build().escaped
            let variablesStr = query.uploads.map({ "\"\($0.id)\":null" }).joined(separator: ",")
            let operations = String(format: "{\"query\": \"%@\",\"variables\": {%@}, \"operationName\": null}", queryStr, variablesStr)
            if let data = operations.data(using: .utf8) {
                multipartFormData.append(data, withName: "operations")
            }
            
            let mapStr = query.uploads
                .map({ String(format: "\"%@\": [\"variables.%@\"]", $0.id, $0.id) })
                .joined(separator: ",")
            
            if let data = "{\(mapStr)}".data(using: .utf8) {
                multipartFormData.append(data, withName: "map")
            }
            
            for upload in query.uploads {
                multipartFormData.append(upload.data, withName: upload.id, fileName: upload.name, mimeType: MimeType(path: upload.name).value)
            }
            
        }, to: clientReference.url,
           usingThreshold: MultipartFormData.encodingMemoryThreshold,
           method: .post,
           headers: httpHeaders,
           requestModifier: clientReference.configuration.requestModifier)
                
        if let customValidation = clientReference.configuration.validation {
            request = request.validate(customValidation)
        }
        self.request = request.validate(GraphusRequest.validateStatus).validate()
    }
    
    private static func validateStatus(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> DataRequest.ValidationResult {
        var rawResponse: String?
        if let data = data {
            rawResponse = String(decoding: data, as: UTF8.self)
        }
        switch response.statusCode {
        case 400: return .failure(GraphusError.client("Bad Request", response.statusCode, rawResponse))
        case 401: return .failure(GraphusError.authentication("Unauthorized", response.statusCode, rawResponse))
        case 402: return .failure(GraphusError.client("Payment Required", response.statusCode, rawResponse))
        case 403: return .failure(GraphusError.authentication("Forbidden", response.statusCode, rawResponse))
        case 404: return .failure(GraphusError.client("Not Found", response.statusCode, rawResponse))
        case 405: return .failure(GraphusError.client("Method Not Allowed", response.statusCode, rawResponse))
        case 406: return .failure(GraphusError.client("Not Acceptable", response.statusCode, rawResponse))
        case 407: return .failure(GraphusError.authentication("Proxy Authentication Required", response.statusCode, rawResponse))
        case 408: return .failure(GraphusError.client("Request Timeout", response.statusCode, rawResponse))
        case 409: return .failure(GraphusError.client("Conflict", response.statusCode, rawResponse))
        case 410: return .failure(GraphusError.client("Gone", response.statusCode, rawResponse))
        case 411: return .failure(GraphusError.client("Length Required", response.statusCode, rawResponse))
        case 412: return .failure(GraphusError.client("Precondition Failed", response.statusCode, rawResponse))
        case 413: return .failure(GraphusError.client("Request Entity Too Large", response.statusCode, rawResponse))
        case 414: return .failure(GraphusError.client("Request-URI Too Long", response.statusCode, rawResponse))
        case 415: return .failure(GraphusError.client("Unsupported Media Type", response.statusCode, rawResponse))
        case 416: return .failure(GraphusError.client("Requested Range Not Satisfiable", response.statusCode, rawResponse))
        case 417: return .failure(GraphusError.client("Expectation Failed", response.statusCode, rawResponse))
        case 500: return .failure(GraphusError.server("Internal Server Error", response.statusCode, rawResponse))
        case 501: return .failure(GraphusError.server("Not Implemented", response.statusCode, rawResponse))
        case 502: return .failure(GraphusError.server("Bad Gateway", response.statusCode, rawResponse))
        case 503: return .failure(GraphusError.server("Service Unavailable", response.statusCode, rawResponse))
        case 504: return .failure(GraphusError.server("Gateway Timeout", response.statusCode, rawResponse))
        case 505: return .failure(GraphusError.server("HTTP Version Not Supported", response.statusCode, rawResponse))
        default: break
        }
        
        return .success(())
    }
    
    private func extractObject(for key: String, from data: Any) throws -> Any {
        
        var currentObj = data
        
        for pathComponent in key.split(separator: ".").map({ String($0) }){
            
            if let index = Int(pathComponent) {
                
                if let dict = currentObj as? [Any], index < dict.count {
                    currentObj = dict[index]
                    
                }else{
                    throw GraphusError.unknownKey(pathComponent)
                }
                
                
            }else{
                
                if let dict = currentObj as? [String: Any?], let nextObj = dict[pathComponent] {
                    if let nextObj = nextObj{
                        currentObj = nextObj
                    }else{
                        throw GraphusError.unknownKey(pathComponent)
                    }
                }else{
                    throw GraphusError.unknownKey(pathComponent)
                }
                
            }
        }
        
        return currentObj
    }
    
}

extension GraphusRequest {
    public class Cancelable {
        private let requst: Alamofire.DataRequest
        internal init(_ requst: Alamofire.DataRequest) {
            self.requst = requst
        }
        public func cancel(){
            self.requst.cancel()
        }
    }
}

// Native
extension GraphusRequest {
    
    @discardableResult
    public func send(queue: DispatchQueue = .main,
                     customRootKey: String? = nil,
                     completionHandler: @escaping (Result<GraphusResponse<Any>, Error>) -> Void) -> GraphusRequest.Cancelable {
        
        self.request.responseJSON(queue: .global(qos: .utility)) { response in
            do {
                
                let statusCode = response.response?.statusCode ?? -999
                let duration = response.metrics?.taskInterval.duration ?? 0
                self.clientReference.logger.responseRecived(name: self.query.name ?? "Unknown",
                                                            statusCode: statusCode,
                                                            duration: duration)
                let value = try response.result.get()
                
                var key = customRootKey ?? self.clientReference.configuration.rootResponseKey
                if customRootKey == nil, let queryName = self.query.alias ?? self.query.name {
                    key += ".\(queryName)"
                }
                let result = try? self.extractObject(for: key, from: value)
                var response = GraphusResponse<Any>(data: result)
                
                if let errorsKey = self.clientReference.configuration.rootErrorsKey,
                    let dict = value as? [AnyHashable: Any],
                    let errors = dict[errorsKey] as? [Any] {
                    response.errors = errors.compactMap({ GraphQLError($0) })
                }
                
                if self.clientReference.configuration.muteCanceledRequests, self.request.isCancelled { return }
                queue.async {
                    completionHandler(.success(response))
                }
                
            } catch {
                if self.clientReference.configuration.muteCanceledRequests,
                    ((error.asAFError?.isExplicitlyCancelledError ?? false) || self.request.isCancelled) {
                    return
                }
                queue.async {
                    completionHandler(.failure(error.asAFError?.underlyingError ?? error))
                }
            }
        }

        self.clientReference.logger.querySended(mode: self.mode,
                                                name: self.query.name ?? "Unknown",
                                                queryString: self.query.build())
        
        return .init(self.request)
        
    }
}

extension GraphusRequest {
    
    /// The request mode
    public enum Mode: String {
        
        /// Queries are used to request the data it needs from the server
        case query
        
        /// Mutations are used to CUD: Create new data, Update existing data, Delete existing data
        case mutation
        
    }
    
}
