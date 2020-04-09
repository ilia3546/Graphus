//
//  Change.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Change {
    var key: String { get set }
    var isForcedToSend: Bool { get set }
    func print(padding: Int)
}

public struct FieldChange: Change, Hashable, Equatable {
    
    public var key: String
    public var isForcedToSend: Bool = false
    public let oldValue: ArgumentValue
    public let newValue: ArgumentValue
    
    public static func == (lhs: FieldChange, rhs: FieldChange) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
    
    public func print(padding: Int) {
        var paddingStr = ""
        for _ in 0 ..< padding { paddingStr += "\t" }
        Swift.print(paddingStr, ".\(self.key + (self.isForcedToSend ? "*" : "")) | ", self.oldValue.argumentValue, "->", self.newValue.argumentValue)
    }
    
}

public struct RootChange: Change, Hashable, Equatable {
    
    public var key: String
    public var isForcedToSend: Bool = false
    public let childChanges: [Change]
    
    public static func == (lhs: RootChange, rhs: RootChange) -> Bool {
        return lhs.key == rhs.key
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.key)
    }
    
    public func print(padding: Int) {
        var paddingStr = ""
        for _ in 0..<padding { paddingStr += "\t" }
        Swift.print(paddingStr, ".\(self.key + (self.isForcedToSend ? "*" : "")) | [")
        for childChange in self.childChanges {
            childChange.print(padding: padding + 1)
        }
        Swift.print(paddingStr, "]")
    }
    
}
