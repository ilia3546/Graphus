//
//  Mutable.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Mutable: ArgumentValue {
    func mutationEncode(to encoder: MutationEncoder)
}

extension Mutable {

    public var argumentValue: String {
        return self.arguments.argumentValue
    }
    
    public var arguments: Arguments {
        let objectEncoder = MutationEncoder()
        if let differetable = self as? Differentable {
            objectEncoder.changeSet = differetable.changeSet
            let fieldsBuilder = FieldsBuilder()
            differetable.alwaysSendUnchangedFields(with: fieldsBuilder)
            objectEncoder.changeExceptFields = fieldsBuilder.fields
        }
        mutationEncode(to: objectEncoder)
        return objectEncoder.fields
    }
    
}

public protocol MutableEnum: ArgumentValue {
    var rawValue: String { get }
}

extension MutableEnum {
    public var argumentValue: String {
        return self.rawValue
    }
}
