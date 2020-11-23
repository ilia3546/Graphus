//
//  Mutable.swift
//  Graphus
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
        if let differetable = self as? Differentiable {
            objectEncoder.changeSet = differetable.changeSet
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
