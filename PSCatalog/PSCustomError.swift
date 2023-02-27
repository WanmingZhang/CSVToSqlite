//
//  PSCustomError.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/26/23.
//

import Foundation

enum PSCustomError: Error, CustomStringConvertible {
    case network(errorDescription: String?)
    case file(errorDescription: String?)
    case database(errorDescription: String?)
    case custom(errorDescription: String?)

    // Throw in all other cases
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .network:
            return "network error"
        case .file:
            return "file error"
        case .database:
            return "database error"
        case .custom:
            return "custom error"
        case .unexpected(_):
            return "An unexpected error occurred."
        }
    }
}

