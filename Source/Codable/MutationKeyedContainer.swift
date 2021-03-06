//
//  MutationKeyedContainer.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class MutationKeyedContainer<Key: CodingKey>: MutationContainer{
    
    public func encodeIfPresent(_ value: ArgumentValue?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encodeIfPresent(value, forKey: key.stringValue)
    }
    
    public func encodeIfPresent(_ value: Date?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encodeIfPresent(value, forKey: key.stringValue)
    }
    
    public func encodeIfPresent(_ value: Upload?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encodeIfPresent(value, forKey: key.stringValue)
    }
    
    public func encodeIfPresent(_ value: [Upload]?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encodeIfPresent(value, forKey: key.stringValue)
    }
    
    public func encode(_ value: ArgumentValue?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encode(value, forKey: key.stringValue)
    }

    public func encode(_ value: Date?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encode(value, forKey: key.stringValue)
    }
    
    public func encode(_ value: Upload?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encode(value, forKey: key.stringValue)
    }
    
    public func encode(_ value: [Upload]?, forKey key: KeyedEncodingContainer<Key>.Key) {
        self.encode(value, forKey: key.stringValue)
    }

}

