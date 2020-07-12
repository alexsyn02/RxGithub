//
//  User.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation

class User: Codable {
    let login: String
    let id: Int
    let avatarUrl: String?
    let url: String?
    let name: String?
    let email: String?
    let bio: String?
    let publicRepos: Int?
    let followers: Int?
    let following: Int?
    let createdAt: String?
    let updatedAt: String?
    let totalPrivateRepos: Int?
    let ownedPrivateRepos: Int?
}
