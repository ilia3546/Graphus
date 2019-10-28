//
//  MutationEncoder.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol MutationContext {}

public class MutationEncoder {
    
    public var fields = [String: ArgumentValue]()
    public var dateFormatter = DateFormatter()
    public var context: MutationContext?
    
    public init() {}
    
    public func container() -> MutationContainer {
        return MutationContainer(self)
    }
    
}
