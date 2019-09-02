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
    internal var uploads = [String: Upload]()
    internal var multipleUploads = [String:[Upload]]()
    public var dateFormatter = DateFormatter()
    
    public func container() -> MutationContainer {
        return MutationContainer(self)
    }
    
}
