//
//  MutationKeyedContainer.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class MutationKeyedContainer<Key: CodingKey>: MutationContainer{
    
    public func encode(_ value: ArgumentValue?, forKey key: KeyedEncodingContainer<Key>.Key) {
        encode(value, forKey: key.stringValue)
    }

    public func encode(_ value: Date?, forKey key: KeyedEncodingContainer<Key>.Key) {
        encode(value, forKey: key.stringValue)
    }

}

