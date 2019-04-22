//
//  MutationContainer.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation


public class MutationContainer{
    
    fileprivate var encoder: MutationEncoder
    public var includeNullValues: Bool
    
    internal init(_ encoder: MutationEncoder){
        self.encoder = encoder
        self.includeNullValues = encoder.includeNullValues
    }
    
    public func encode(_ value: ArgumentValue?, forKey key: String) {
        if let value = value{
            encoder.fields[key] = value.argumentValue
        }else{
            encodeNull(forKey: key)
        }
    }
    
    
    public func encode(_ value: Date?, forKey key: String) {
        if let value = value{
            let dateValue = encoder.dateFormatter.string(from: value)
            encoder.fields[key] = "\"\(dateValue)\""
        }else{
            encodeNull(forKey: key)
        }
    }
    
    private func encodeNull(forKey key: String){
        if encoder.includeNullValues {
            encoder.fields[key] = "null"
        }
    }
    
}

