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

    public var mode: Mode
    public var query: Query
    private var clientReference: GraphusClient
    
    internal let request: UploadRequest
    
    init(_ mode: Mode = .query, query: Query, clientReference: GraphusClient) {
        self.clientReference = clientReference
        self.query = query
        self.mode = mode
                
        var httpHeaders = clientReference.configuration.httpHeaders ?? []
        if !httpHeaders.contains(where: { $0.name.lowercased() == "user-agent" }),
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            httpHeaders.add(name: "User-Agent", value: "Graphus /\(version)")
        }

        self.request = clientReference.session.upload(multipartFormData: { multipartFormData in
            
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
                multipartFormData.append(upload.data, withName: upload.id)
            }
            
        }, to: clientReference.url, usingThreshold: MultipartFormData.encodingMemoryThreshold, method: .post, headers: httpHeaders, interceptor: nil, fileManager: .default, requestModifier: clientReference.configuration.requestModifier)
        
    }
    
    private func validateGraphErrors(_ value: Any) throws -> [GraphQLError] {
        
        if let response = value as? [String: Any] {
            if let errorType = response["error"] as? String,
                errorType == "invalid_grant" || errorType == "access_denied",
                let errorDescription = response["error_description"] as? String {
                throw GraphusError.authentication(errorDescription)
                
            }else if let errorDescription = response["error_description"] as? String {
                // Test oAuth error
                throw GraphusError.serverError(errorDescription)
                
            }else if let errorMsg = response["errorMsg"] as? String {
                // Test server errors
                throw GraphusError.serverError(errorMsg)
                
            }else if let errorsKey = self.clientReference.configuration.rootErrorsKey,
                let errors = response[errorsKey] as? [Any] {
                return errors.compactMap({ GraphQLError($0) })
                
            }
            
        }
        
        return []
        
    }
    
    private func checkStatusCode(_ statusCode: Int) throws {
        switch statusCode {
        case 400: throw GraphusError.client("Bad Request")
        case 401: throw GraphusError.authentication("Unauthorized")
        case 402: throw GraphusError.client("Payment Required")
        case 403: throw GraphusError.authentication("Forbidden")
        case 404: throw GraphusError.client("Not Found")
        case 405: throw GraphusError.client("Method Not Allowed")
        case 406: throw GraphusError.client("Not Acceptable")
        case 407: throw GraphusError.authentication("Proxy Authentication Required")
        case 408: throw GraphusError.client("Request Timeout")
        case 409: throw GraphusError.client("Conflict")
        case 410: throw GraphusError.client("Gone")
        case 411: throw GraphusError.client("Length Required")
        case 412: throw GraphusError.client("Precondition Failed")
        case 413: throw GraphusError.client("Request Entity Too Large")
        case 414: throw GraphusError.client("Request-URI Too Long")
        case 415: throw GraphusError.client("Unsupported Media Type")
        case 416: throw GraphusError.client("Requested Range Not Satisfiable")
        case 417: throw GraphusError.client("Expectation Failed")
        case 500: throw GraphusError.serverError("Internal Server Error")
        case 501: throw GraphusError.serverError("Not Implemented")
        case 502: throw GraphusError.serverError("Bad Gateway")
        case 503: throw GraphusError.serverError("Service Unavailable")
        case 504: throw GraphusError.serverError("Gateway Timeout")
        case 505: throw GraphusError.serverError("HTTP Version Not Supported")
        default: break
        }
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
        private let requst: UploadRequest
        internal init(_ requst: UploadRequest) {
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
                
                let graqhQlErrors = try self.validateGraphErrors(value)
                var key = customRootKey ?? self.clientReference.configuration.rootResponseKey
                if customRootKey == nil, let queryName = self.query.alias ?? self.query.name {
                    key += ".\(queryName)"
                }
                let result = try? self.extractObject(for: key, from: value)
                var response = GraphusResponse<Any>(data: result)
                response.errors = graqhQlErrors
                
                queue.async {
                    completionHandler(.success(response))
                }
                
            } catch {
                queue.async {
                    completionHandler(.failure(error))
                }
            }
        }

        self.clientReference.logger.querySended(mode: self.mode,
                                                name: self.query.name ?? "Unknown",
                                                queryString: self.query.build())

        /*
        
        self.complectionBlock = { statusCode, res, internalError, graphsErrors in
            
            self.client.logger.responseRecived(name: self.query.name ?? "?", statusCode: statusCode ?? -999, duration: Date().timeIntervalSince(startDate))
            
            if let error = internalError {
                guard self.sessionDataTask.state != .canceling else { return }
                (queue ?? .main).async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            (queue ?? .main).async {
                
                var key = customRootKey ?? "\(self.client.rootResponseKey)"
                
                if customRootKey == nil, let queryName = self.query.alias ?? self.query.name {
                    key += ".\(queryName)"
                }
                
                var data: Any?
                if let res = res {
                    data = try? self.extractObject(for: key, from: res)
                }
                
                var response = GraphusResponse<Any>(data: data)
                response.errors = graphsErrors
                
                guard self.sessionDataTask.state != .canceling else { return }
                completionHandler(.success(response))
                
            }
            
        }


        if self.sessionDataTask.state == .completed {
            let urlRequest = GraphusRequest.createRequest(self.mode, query: self.query, client: self.client)
            self.sessionDataTask = self.client.session.dataTask(with: urlRequest, completionHandler: responseHandler)
        }
        
        self.sessionDataTask.resume()
*/
        
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
