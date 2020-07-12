//
//  CustomError.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 11.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

enum CustomError: LocalizedError {
    case responseError(statusCode: Int, description: String)
    case invalidURLError
    case parseError
    case openURLError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case let .responseError(_, description):
            return description
        case .invalidURLError:
            return "Invalid URL."
        case .parseError:
            return "Error during parsing."
        case .openURLError:
            return "There is no opportunity to open this repository on your phone."
        case .unknownError:
            return "Unknown error."
        }
    }
}
