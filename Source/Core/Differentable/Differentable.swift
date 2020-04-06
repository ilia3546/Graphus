//
//  Differentable.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03.04.2020.
//  Copyright © 2020 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol Differentable: Mutable {
    var changeSet: ChangeSet? { get set }
    func alwaysSendUnchangedFields(with builder: FieldsBuilder)
}

extension Differentable {
    public func alwaysSendUnchangedFields(with builder: FieldsBuilder) {}
}
