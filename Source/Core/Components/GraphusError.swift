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
    case server(_ message: String, _ code: Int, _ rawResponse: String?)
    case authentication(_ message: String, _ code: Int, _ rawResponse: String?)
    case client(_ message: String, _ code: Int, _ rawResponse: String?)
    
    public var rawResponse: String? {
        switch self {
        case .authentication(_, _, let rawResponse):
            return rawResponse
        case .client(_, _, let rawResponse):
            return rawResponse
        case .server(_, _, let rawResponse):
            return rawResponse
        default:
            return nil
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .authentication(_, let code, _):
            return code
        case .client(_, let code, _):
            return code
        case .server(_, let code, _):
            return code
        default:
            return nil
        }
    }
    
}

extension GraphusError: LocalizedError {
    
    public var localizedDescription: String {
        switch self {
        case .authentication(let message, _, _):
            return message
        case .responseDataIsNull:
            return "Response data is null"
        case .server(let message, _, _):
            return message
        case .client(let message, _, _):
            return message
        case .unknownKey(let key):
            return "Unknown key \"\(key)\""
        }
    }
    
    public var errorDescription: String? {
        return self.localizedDescription
    }
    
}

extension GraphusError: CustomNSError {
    
    public static var errorDomain: String {
        return "Graphus.GraphusError"
    }
    
    public var errorCode: Int {
        return self.statusCode ?? 0
    }
    
    public var errorUserInfo: [String : Any] {
        if let rawResponse = self.rawResponse {
            return ["raw_response": rawResponse]
        }
        return [:]
    }
    
}
