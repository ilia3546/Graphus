//
//  StringCodingKey.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 21.10.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

/// A generic `String` based `CodingKey` implementation.
public struct StringCodingKey: CodingKey {
    /// `CodingKey` conformance.
    public var stringValue: String
    
    /// `CodingKey` conformance.
    public var intValue: Int? {
        return Int(self.stringValue)
    }
    
    /// Creates a new `StringCodingKey`.
    public init(_ string: String) {
        self.stringValue = string
    }
    
    /// `CodingKey` conformance.
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    /// `CodingKey` conformance.
    public init(intValue: Int) {
        self.stringValue = intValue.description
    }
}
