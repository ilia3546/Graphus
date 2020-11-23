//
//  FieldsBuilder + Coding.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public struct AbstractDecodingContainer<T: AbstractType> {
    let type: T
    let singleValueContainer: SingleValueDecodingContainer

    func decode<Z: Decodable>() throws -> Z {
        return try self.singleValueContainer.decode(Z.self)
    }
}

private enum TypeNameCodingKey: String, CodingKey {
    case typename = "__typename"
}

extension Decoder {
    
    func abstractContainer<T: AbstractType>(_ type: T.Type) throws -> AbstractDecodingContainer<T> {
        let container = try self.container(keyedBy: TypeNameCodingKey.self)
        let nestedType = try container.decode(type.self, forKey: .typename)
        let singleValueContainer = try self.singleValueContainer()
        return AbstractDecodingContainer(type: nestedType, singleValueContainer: singleValueContainer)
    }
    
}
