//
//  GithubError.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 11.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

class GithubError: Codable {
    let documentationUrl: String
    let message: String
}
