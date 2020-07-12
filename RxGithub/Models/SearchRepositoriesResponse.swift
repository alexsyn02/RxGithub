//
//  SearchRepositoriesResponse.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

class SearchRepositoriesResponse: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Repository]
}
