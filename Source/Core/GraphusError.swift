//
//  InternalError.swift
//  Graphus
//
//  Created by Ilya Kharlamov on 05/04/2019.
//

import Foundation


public enum GraphusError: Error {
    case unknownKey(String)
    case responseDataIsNull
    case serverError(String)
    case invalidGrand(String)
}

extension GraphusError: LocalizedError {
    
    public var localizedDescription: String {
        switch self {
        case .invalidGrand(let message):
            return message
        case .responseDataIsNull:
            return "Response data is null"
        case .serverError(let message):
            return message
        case .unknownKey(let key):
            return "Unknown key \"\(key)\""
        }
    }
    
    public var errorDescription: String? {
        return self.localizedDescription
    }
    
}
