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
                multipartFormData.append(upload.data, withName: upload.id, fileName: upload.name, mimeType: MimeType(path: upload.name).value)
            }
            
        }, to: clientReference.url,
           usingThreshold: MultipartFormData.encodingMemoryThreshold,
           method: .post,
           headers: httpHeaders,
           requestModifier: clientReference.configuration.requestModifier).validate()
        
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
                
                let graqhQlErrors = try self.validateGraphErrors(value)
                var key = customRootKey ?? self.clientReference.configuration.rootResponseKey
                if customRootKey == nil, let queryName = self.query.alias ?? self.query.name {
                    key += ".\(queryName)"
                }
                let result = try? self.extractObject(for: key, from: value)
                var response = GraphusResponse<Any>(data: result)
                response.errors = graqhQlErrors
                
                if self.clientReference.configuration.muteCanceledRequests, self.request.isCancelled { return }
                queue.async {
                    completionHandler(.success(response))
                }
                
            } catch {
                if self.clientReference.configuration.muteCanceledRequests {
                    if let error = error as? AFError, error.isExplicitlyCancelledError {
                        return
                    } else if self.request.isCancelled {
                        return
                    }
                }
                queue.async {
                    completionHandler(.failure(error))
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
