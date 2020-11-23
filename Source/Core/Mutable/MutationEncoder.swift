//
//  MutationEncoder.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 27/02/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public class MutationEncoder {
    
    public var fields = [String: ArgumentValue]()
    public var dateFormatter = DateFormatter()
    public var isChangesetReloading: Bool = false
    internal var changeSet: ChangeSet?

    public init() {}
    
    public func container() -> MutationContainer {
        return MutationContainer(self)
    }
    
}
