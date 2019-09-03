//
//  Upload.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 03/09/2019.
//  Copyright © 2019 Bluetech LLC. All rights reserved.
//

import Foundation

public struct Upload: ArgumentValue {
    
    internal let id: String
    public var data: Data
    public var name: String
    public var nullable: Bool = false
    
    public init(_ data: Data, name: String) {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        self.id = String((0..<16).map{ _ in letters.randomElement()! })
        self.data = data
        self.name = name
    }
    
    public init(url: URL) throws {
        let fileData = try NSData(contentsOf: url, options: []) as Data
        self.init(fileData, name: url.lastPathComponent)
    }
    
    public var argumentValue: String {
        return "$\(self.id)"
    }
    
    var contentType: String {
        return MimeType(path: self.name).value
    }
    
}

