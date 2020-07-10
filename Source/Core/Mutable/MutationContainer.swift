//
//  MutationContainer.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class MutationContainer {
    
    fileprivate var encoder: MutationEncoder
    
    internal init(_ encoder: MutationEncoder){
        self.encoder = encoder
    }
    
    fileprivate func differenceEncode<T>(_ value: T?, forKey key: String, _ complection: (T?) -> Void) {
        
        guard let changeSet = self.encoder.changeSet else {
            complection(value)
            return
        }
        
        if let change = changeSet.first(where: key) {
            if let rootChange = change as? RootChange {
                if var value = value as? Differentiable {
                    value.changeSet = ChangeSet(changes: rootChange.childChanges)
                    complection(value as? T)
                } else {
                    complection(value)
                }
            } else if let fieldChange = change as? FieldChange {
                complection(fieldChange.newValue as? T ?? value)
            }
        }
        
    }
    
    public func encodeIfPresent(_ value: ArgumentValue?, forKey key: String) {
        if let value = value {
            self.differenceEncode(value, forKey: key) { value in
                self.encoder.fields[key] = value
            }
        }
    }
    
    public func encodeIfPresent(_ value: Date?, forKey key: String) {
        if let value = value{
            let dateValue = self.encoder.dateFormatter.string(from: value)
            self.differenceEncode(dateValue, forKey: key) { value in
                self.encoder.fields[key] = dateValue
            }
        }
    }
    
    public func encode(_ value: ArgumentValue?, forKey key: String) {
        if let value = value {
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
        self.differenceEncode(NSNull(), forKey: key) { value in
            self.encoder.fields[key] = value
        }
    }
    
}
