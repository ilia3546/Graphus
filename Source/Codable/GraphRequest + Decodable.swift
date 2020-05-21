//
//  GraphRequest + Decodable.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation
import Alamofire

extension GraphusRequest {
    
    @discardableResult
    public func send<T: Decodable>(mapToDecodable object: T.Type,
                                   customRootKey: String? = nil,
                                   queue: DispatchQueue = .main,
                                   customDecoder: JSONDecoder? = nil,
                                   completionHandler: @escaping (Result<GraphusResponse<T>, Error>) -> Void) -> GraphusRequest.Cancelable {
        
        return self.send(queue: .global(qos: .utility), customRootKey: customRootKey) { result in
            
            do{
                
                let response = try result.get()
                var mappedData: T?
                
                if let data = response.data as? T {
                    mappedData = data
                }else if let data = response.data {
                    let data = try JSONSerialization.data(withJSONObject: data, options: [])
                    let decoder = customDecoder ?? JSONDecoder()
                    mappedData = try decoder.decode(T.self, from: data)
                }
                
                var newResponse = GraphusResponse<T>(data: mappedData)
                newResponse.errors = response.errors
                
                if self.clientReference.configuration.muteCanceledRequests, self.request.isCancelled { return }
                queue.async {
                    completionHandler(.success(newResponse))
                }
                
            }catch{
                if self.clientReference.configuration.muteCanceledRequests, self.request.isCancelled { return }
                queue.async {
                    completionHandler(.failure(error))
                }
            }
            
        }
   
    }
}

