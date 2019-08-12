//
//  InternalError.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 05/04/2019.
//

import Foundation

public struct GraphusError: Error {
    
    public enum `Type`: String {
        case unknownKey
        case responseDataIsNull
        case serverError
        case graphQLError
        case invalidGrand
        case unknown
    }
    
    public var type: Type
    fileprivate var description: String?
    public var query: Query?
    public var request: URLRequest?
    
    public init(type: Type = .unknown, query: Query?, request: URLRequest?) {
        self.type = type
        self.query = query
        self.request = request
    }
    
    public init(_ error: Error, type: Type = .unknown, query: Query?, request: URLRequest?) {
        self.description = error.localizedDescription
        self.type = type
        self.query = query
        self.request = request
    }
    
    public init(_ string: String, type: Type = .unknown, query: Query?, request: URLRequest?) {
        self.description = string
        self.type = type
        self.query = query
        self.request = request
    }
    
}

extension GraphusError: LocalizedError {
    public var errorDescription: String? {
        switch self.type {
        case .responseDataIsNull:
            return "Response data is null"
        default:
            return self.description
        }
    }
}
