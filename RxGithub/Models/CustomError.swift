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
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case let .responseError(_, description):
            return description
        case .invalidURLError:
            return "Invalid URL."
        case .parseError:
            return "Error during parsing."
        case .unknownError:
            return "Unknown error."
        }
    }
}
