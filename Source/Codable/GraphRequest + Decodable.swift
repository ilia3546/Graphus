//
//  GraphRequest + Decodable.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

extension GraphusRequest {
    
    @discardableResult
    public func send<T: Decodable>(mapToDecodable object: T.Type,
                                        customRootKey: String? = nil,
                                         queue: DispatchQueue? = nil,
                                         customDecoder: JSONDecoder? = nil,
                                         completionHandler: @escaping (Result<GraphusResponse<T>, GraphusError>) -> Void) -> GraphusRequest.Cancelable {
        
        return send(queue: .global(qos: .background), customRootKey: customRootKey) { result in

            do{
                
                let response = try result.get()
                let mappedData: T!
                
                if let data = response.data as? T {
                    mappedData = data
                }else{
                    let data = try JSONSerialization.data(withJSONObject: response.data, options: [])
                    let decoder = customDecoder ?? JSONDecoder()
                    mappedData = try decoder.decode(T.self, from: data)
                }
                
                var newResponse = GraphusResponse<T>(data: mappedData)
                newResponse.errors = response.errors
                
                (queue ?? .main).async {
                    completionHandler(.success(newResponse))
                }
                
            }catch{
                (queue ?? .main).async {
                    if let error = error as? GraphusError {
                        completionHandler(.failure(error))
                    }else{
                        completionHandler(.failure(.otherError(error)))
                    }
                }
            }
           
        }
    }
}

