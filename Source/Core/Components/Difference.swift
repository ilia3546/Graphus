//
//  Difference.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 24.10.2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Difference {
    var key: String { get set }
}

public struct DifferenceItem: Difference, Hashable, Equatable {
    public var key: String
    public let oldValue: ArgumentValue
    public let newValue: ArgumentValue
    public static func == (lhs: DifferenceItem, rhs: DifferenceItem) -> Bool {
        return lhs.key == rhs.key
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
}

public struct DifferenceRoot: Difference, Hashable, Equatable {
    public var key: String
    public let childDifferences: [Difference]
    public static func == (lhs: DifferenceRoot, rhs: DifferenceRoot) -> Bool {
        return lhs.key == rhs.key
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
}

extension Mutable {
        
    public func differences(from oldObject: Mutable) -> [Difference] {
        
        let oldEncoder = MutationEncoder()
        let newEncoder = MutationEncoder()
        oldObject.mutationEncode(to: oldEncoder)
        self.mutationEncode(to: newEncoder)
        let oldFields = oldEncoder.fields
        let newFields = newEncoder.fields
        var diffFields = [Difference]()
        
        for newField in newFields {
            guard let oldField = oldFields.first(where: { $0.key == newField.key }) else {
                continue
            }
            if let oldValue = oldField.value as? Mutable, let newValue = newField.value as? Mutable {
                let childDiffFields = newValue.differences(from: oldValue)
                if !childDiffFields.isEmpty {
                    diffFields.append(DifferenceRoot(key: newField.key, childDifferences: childDiffFields))
                }
                continue
            }
            if oldField.value.argumentValue != newField.value.argumentValue {
                diffFields.append(DifferenceItem(key: newField.key, oldValue: oldField.value, newValue: newField.value))
            }
        }
        
        return diffFields
    }
    
}
