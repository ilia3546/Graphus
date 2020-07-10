//
//  Differentiable.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Differentiable: Mutable {
    var changeSet: ChangeSet? { get set }
    func alwaysSendUnchangedFields(with builder: FieldsBuilder)
}

extension Differentiable {
    public func alwaysSendUnchangedFields(with builder: FieldsBuilder) {}
    internal var alwaysSendableUnchangedFields: [String] {
        let fieldsBuilder = FieldsBuilder()
        self.alwaysSendUnchangedFields(with: fieldsBuilder)
        return fieldsBuilder.fields
    }
}
