//
//  GraphClient.swift
//  AeroGraph
//
//  Created by Ilya Kharlamov on 15/03/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public protocol AbstractType: Codable {
    var rawValue: String { get }
}
