//
//  Request.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class GraphusRequest {
    
    enum Mode: String {
        case query, mutation
    }
    
    var mode: Mode
    var query: Query
    var client: GraphusClient
    var sessionDataTask: URLSessionDataTask!
    
    private var complectionBlock: ((Int?, Any?, Error?, [GraphusError]) -> Void)?
    
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
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.addValue("AeroGraph / \(version)", forHTTPHeaderField: "User-Agent")
        }
        
        let params = ["query": mode.rawValue + query.build()]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        return request
    }
    
    
    private func validateGraphErrors(_ data: Data, response: URLResponse?) throws -> [GraphusError] {
        let currentObj = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let response = currentObj as? [String: Any]{
            
            if let errorDescription = response["error_description"] as? String {
                // Test oAuth error
                throw GraphusError.serverError(errorDescription)
                
            }else if let errorMsg = response["errorMsg"] as? String {
                // Test server errors
                throw GraphusError.serverError(errorMsg)
                
            }else if let errors = response["errors"] as? [[String: Any]] {
                
                return errors.compactMap({
                    if let errorMessage = $0["message"] as? String {
                        return GraphusError.serverError(errorMessage)
                    }else{
                        return nil
                    }
                })
                
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
                           completionHandler: @escaping (Result<GraphusResponse<Any>, GraphusError>) -> Void) -> GraphusRequest.Cancelable {
        
        if client.debugParams.contains(.logSendedRequests) {
            print("[Graphus] send request \"\(query.name)\"")
        }

        if client.debugParams.contains(.printSendableQueries) {
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
                    completionHandler(.failure(.otherError(error)))
                }
                return
            }
            
            (queue ?? .main).async {
                let key = customRootKey ?? "\(self.client.rootResponseKey).\(self.query.name)"
                if let res = res,
                    let data = try? self.extractObject(for: key, from: res) {
                    
                    var response = GraphusResponse<Any>(data: data)
                    response.errors = graphsErrors
                    completionHandler(.success(response))
                    
                }else if let error = graphsErrors.first {
                    completionHandler(.failure(error))
                }else{
                    completionHandler(.failure(.responseDataIsNull))
                }
            }
            
        }

        sessionDataTask.resume()

        return .init(sessionDataTask)
        
    }
}
