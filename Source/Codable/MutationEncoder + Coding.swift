//
//  MutationEncoder + Coding.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

extension MutationEncoder {
    public func container<Key>(keyedBy type: Key.Type) -> MutationKeyedContainer<Key> where Key : CodingKey {
        return MutationKeyedContainer<Key>(self)
    }
}
