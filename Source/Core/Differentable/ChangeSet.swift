//
//  ChangeSet.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public struct ChangeSet: Codable {
    
    public let changes: [Change]
    
    public init(from decoder: Decoder) throws {
        try self.init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {}

    internal init(changes: [Change]) {
        self.changes = changes
    }
    
    public init(source: Differentiable, target: Differentiable) {
        
        // Get new fields
        let newEncoder = MutationEncoder()
        newEncoder.isChangesetReloading = true
        var newMutableInstance = target
        newMutableInstance.changeSet = nil
        newMutableInstance.mutationEncode(to: newEncoder)
        let newFields = newEncoder.fields
        
        // Get old fields
        let oldEncoder = MutationEncoder()
        oldEncoder.isChangesetReloading = true
        var oldMutableInstance = source
        oldMutableInstance.changeSet = nil
        oldMutableInstance.mutationEncode(to: oldEncoder)
        let oldFields = oldEncoder.fields

        var changes: [Change] = []
        
        // Compare earch new field with old field
        for newField in newFields {
            
            // If old fields doesnt exists, add FieldChange[ null -> newValue ]
            guard let oldField = oldFields.first(where: { $0.key == newField.key }) else {
                changes.append(FieldChange(key: newField.key, oldValue: NSNull(), newValue: newField.value))
                continue
            }
                        
            // Compare mutable object
            if let oldValue = oldField.value as? Differentiable, let newValue = newField.value as? Differentiable {
                let childChangeSet = ChangeSet(source: oldValue, target: newValue)
                var rootChange = RootChange(key: newField.key, childChanges: childChangeSet.changes)
                if childChangeSet.hasChangedFields {
                    changes.append(rootChange)
                } else if target.alwaysSendableUnchangedFields.contains(newField.key) {
                    rootChange.isForcedToSend = true
                    changes.append(rootChange)
                }
                continue
            }
            
            // Compare hashable object
            if let oldValue = (oldField.value as Any) as? AnyHashable, let newValue = (newField.value as Any) as? AnyHashable {
                var fieldChange = FieldChange(key: newField.key, oldValue: oldField.value, newValue: newField.value)
                if oldValue != newValue {
                    changes.append(fieldChange)
                } else if target.alwaysSendableUnchangedFields.contains(newField.key) {
                    fieldChange.isForcedToSend = true
                    changes.append(fieldChange)
                }
                continue
            }
            
            // Compare argument values
            var fieldChange = FieldChange(key: newField.key, oldValue: oldField.value, newValue: newField.value)
            if oldField.value.argumentValue != newField.value.argumentValue {
                changes.append(fieldChange)
            } else if target.alwaysSendableUnchangedFields.contains(newField.key) {
                fieldChange.isForcedToSend = true
                changes.append(fieldChange)
            }
            
        }
        
        self.init(changes: changes)
        
    }
    
    internal func contains(_ key: String) -> Bool {
        return self.changes.contains(where: { $0.key == key })
    }
    
    internal func contains(_ key: CodingKey) -> Bool {
        return self.contains(key.stringValue)
    }
    
    public var hasChangedFields: Bool {
        return !self.changes.filter({ !$0.isForcedToSend }).isEmpty
    }
    
    public func first(where key: CodingKey) -> Change? {
        return self.first(where: key.stringValue)
    }
    
    public func first(where key: String) -> Change? {
        return self.changes.first(where: { $0.key == key })
    }
    
}

extension ChangeSet: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        return self.changes.map({ $0.description(padding: 0) }).joined(separator: "\n")
    }
    
}
