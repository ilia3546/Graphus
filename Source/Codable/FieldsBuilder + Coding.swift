//
//  FieldsBuilder + Coding.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

extension FieldsBuilder {
    /// Query
    public func container<Key>(keyedBy type: Key.Type) -> FieldsKeyedContainer<Key> where Key : CodingKey {
        return FieldsKeyedContainer<Key>(self)
    }
}
