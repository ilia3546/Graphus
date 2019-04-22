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
    case graphQLError(String)
    case otherError(Error)
    case invalidGrand(String)
    
}

extension GraphusError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .responseDataIsNull:
            return "Response data is null"
        case .serverError(let str):
            return str
        case .graphQLError(let str):
            return str
        case .invalidGrand(let str):
            return str
        case .unknownKey(let key):
            return "Unknown key \"\(key)\""
        case .otherError(let error):
            return error.localizedDescription
        }
    }
}
