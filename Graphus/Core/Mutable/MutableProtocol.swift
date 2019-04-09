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
        let objectEncoder = MutationEncoder()
        mutationEncode(to: objectEncoder)
        let objectVal = objectEncoder.fields.map({ "\($0):\($1)" }).joined(separator: ",")
        return "{\(objectVal)}"
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
