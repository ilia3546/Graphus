//
//  Request.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class GraphusRequest {
    
    public  enum Mode: String {
        case query, mutation
    }
    
    public var mode: Mode
    public var query: Query
    public var client: GraphusClient
    var sessionDataTask: URLSessionDataTask!
    
    private var complectionBlock: ((Int?, Any?, Error?, [GraphQLError]) -> Void)?
    
    init(query: Query, mode: Mode, client: GraphusClient) {
        self.client = client
        self.query = query
        self.mode = mode
        
        let urlRequest = GraphusRequest.createRequest(query: query, mode: mode, client: client)
        self.sessionDataTask = client.session.dataTask(with: urlRequest, completionHandler: responseHandler)

    }
    
    private static func createRequest(query: Query, mode: Mode, client: GraphusClient) -> URLRequest {
        var request = URLRequest(url: client.url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var isUserAgentExists = false
        
        if let headers = client.session.configuration.httpAdditionalHeaders,
            let _ = headers["User-Agent"] ?? headers["User-agent"] ?? headers["user-agent"] ?? headers["user-Agent"] {
            isUserAgentExists = true
        }
        
        if !isUserAgentExists, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.addValue("Graphus /\(version)", forHTTPHeaderField: "User-Agent")
        }
        
        let params = ["query": mode.rawValue + query.build()]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        return request
    }
    
    
    private func validateGraphErrors(_ data: Data, response: URLResponse?) throws -> [GraphQLError] {
        let currentObj = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let response = currentObj as? [String: Any]{
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
                
            }else if let errorsKey = self.client.rootErrorsKey,
                let errors = response[errorsKey] as? [Any] {
                return errors.compactMap({ GraphQLError($0) })
                
            }
            
        }
        
        return []
        
    }
    
    private func responseHandler(data: Data?, response: URLResponse?, error: Error?){
        
        let statusCode = (response as? HTTPURLResponse)?.statusCode
       
        if let error = error {
            self.complectionBlock?(statusCode, nil, error, [])
            return
        }
        
        do{
            
            guard let data = data else {
                throw GraphusError.responseDataIsNull
            }
            
            let graphErrors = try validateGraphErrors(data, response: response)
            
            if let statusCode = statusCode {
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
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            self.complectionBlock?(statusCode, jsonObject, nil, graphErrors)
            
        }catch{
            self.complectionBlock?(statusCode, nil, error, [])
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
        
        private var sessionDataTask: URLSessionDataTask
        internal init(_ sessionDataTask: URLSessionDataTask) {
            self.sessionDataTask = sessionDataTask
        }
        
        public func cancel(){
            self.sessionDataTask.cancel()
        }
        
    }
}



// Native
extension GraphusRequest {
    
    @discardableResult
    public func send(queue: DispatchQueue? = nil,
                     customRootKey: String? = nil,
                           completionHandler: @escaping (Result<GraphusResponse<Any>, Error>) -> Void) -> GraphusRequest.Cancelable {
        
        if self.client.debugParams.contains(.logSendedRequests) {
            print("[Graphus] send request \"\(query.name)\"")
        }

        if self.client.debugParams.contains(.printSendableQueries) {
            print("[Graphus] request query \"", mode.rawValue, query.build(), "\"")
        }

        let startDate = Date()
        
        self.complectionBlock = { statusCode, res, internalError, graphsErrors in
            
            if self.client.debugParams.contains(.logRequestAmountTime) {
                let duration = String(format: "%.3f", Date().timeIntervalSince(startDate))
                print("[Graphus] response for method \"\(self.query.name)\", \(statusCode ?? -999), \(duration)s")
            }
            
            if let error = internalError {
                (queue ?? .main).async {
                    completionHandler(.failure(error))
                }
                return
            }
            
            (queue ?? .main).async {
                let key = customRootKey ?? "\(self.client.rootResponseKey).\(self.query.name)"
                var data: Any?
                if let res = res {
                    data = try? self.extractObject(for: key, from: res)
                }
                
                var response = GraphusResponse<Any>(data: data)
                response.errors = graphsErrors
                completionHandler(.success(response))
                
            }
            
        }


        if self.sessionDataTask.state == .completed {
            let urlRequest = GraphusRequest.createRequest(query: query, mode: mode, client: client)
            self.sessionDataTask = client.session.dataTask(with: urlRequest, completionHandler: responseHandler)
        }
        
        self.sessionDataTask.resume()

        return .init(self.sessionDataTask)
        
    }
}
