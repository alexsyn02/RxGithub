//
//  Repository.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

class Repository: Codable {
    let id: Int
    let nodeId: String?
    let name: String?
    let fullName: String?
    let `private`: Bool?
    let owner: User?
    let htmlUrl: String?
    let description: String?
    let fork: Bool
    let url: String?
    let forksUrl: String?
    let createdAt: String?
    let updatedAt: String?
    let pushedAt: String?
    let homepage: String?
    let size: Int?
    let stargazersCount: Int?
    let watchersCount: Int?
    let language: String?
    let forksCount: Int?
    let forks: Int?
    let watchers: Int?
    let defaultBranch: String?
    let score: Double?
}
