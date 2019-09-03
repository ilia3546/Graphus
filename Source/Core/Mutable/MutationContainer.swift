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
    
    internal init(_ encoder: MutationEncoder){
        self.encoder = encoder
    }
    
    public func encodeIfPresent(_ value: ArgumentValue?, forKey key: String) {
        if let value = value {
            self.encoder.fields[key] = value
        }
    }
    
    public func encodeIfPresent(_ value: Date?, forKey key: String) {
        if let value = value{
            let dateValue = self.encoder.dateFormatter.string(from: value)
            self.encoder.fields[key] = dateValue
        }
    }
    
    public func encode(_ value: ArgumentValue?, forKey key: String) {
        if let value = value{
            self.encodeIfPresent(value, forKey: key)
        }else{
            self.encodeNull(forKey: key)
        }
    }
    
    public func encode(_ value: Date?, forKey key: String) {
        if let value = value {
            self.encodeIfPresent(value, forKey: key)
        }else{
            self.encodeNull(forKey: key)
        }
    }
    
    private func encodeNull(forKey key: String){
        self.encoder.fields[key] = NSNull()
    }
    
}
