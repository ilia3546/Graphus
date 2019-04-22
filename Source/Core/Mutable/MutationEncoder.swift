//
//  MutationEncoder.swift
//  RetailSDK
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation


public class MutationEncoder {
    
    internal var fields = [String: String]()
    public var dateFormatter = DateFormatter()
    public var includeNullValues = false
    
    public func container() -> MutationContainer {
        return MutationContainer(self)
    }
    
}
