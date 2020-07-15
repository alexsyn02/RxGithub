//
//  Repository.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation
import RealmSwift

class Repository: Codable {
    let id: Int
//    let nodeId: String?
//    let name: String?
    let fullName: String?
//    let `private`: Bool?
//    let owner: User?
    let htmlUrl: String?
    let description: String?
//    let fork: Bool?
//    let url: String?
//    let forksUrl: String?
//    let createdAt: String?
//    let updatedAt: String?
//    let pushedAt: String?
//    let homepage: String?
//    let size: Int?
//    let stargazersCount: Int?
//    let watchersCount: Int?
//    let language: String?
//    let forksCount: Int?
//    let forks: Int?
//    let watchers: Int?
//    let defaultBranch: String?
    let score: Double?
    var isViewed: Bool?
    var isLocal: Bool?
    
    init(repositoryRealm object: RepositoryRealm) {
        self.id = object.id
        self.fullName = object.fullName
        self.htmlUrl = object.htmlUrl
        self.description = object.repositoryDescription
        self.score = object.score
        self.isViewed = false
        self.isLocal = true
    }
}

class RepositoryRealm: Object {
    @objc dynamic var id: Int = 0
//    dynamic var nodeId: String?
//    dynamic var name: String?
    @objc dynamic var fullName: String?
//    dynamic var `private`: Bool?
//    dynamic var owner: User?
    @objc dynamic var htmlUrl: String?
    @objc dynamic var repositoryDescription: String?
//    dynamic var fork: Bool?
//    dynamic var url: String?
//    dynamic var forksUrl: String?
//    dynamic var createdAt: String?
//    dynamic var updatedAt: String?
//    dynamic var pushedAt: String?
//    dynamic var homepage: String?
//    dynamic var size: Int?
//    dynamic var stargazersCount: Int?
//    dynamic var watchersCount: Int?
//    dynamic var language: String?
//    dynamic var forksCount: Int?
//    dynamic var forks: Int?
//    dynamic var watchers: Int?
//    dynamic var defaultBranch: String?
    @objc dynamic var score: Double = 0

    override class func primaryKey() -> String? {
        return "id"
    }
    
    required init() {}
    
    init(repository: Repository) {
        self.id = repository.id
        self.fullName = repository.fullName
        self.htmlUrl = repository.htmlUrl
        self.repositoryDescription = repository.description
        self.score = repository.score ?? 0
    }
}

class RepositoryArrayRealm: Object {
    @objc dynamic var id = 0
    dynamic var repositories = List<RepositoryRealm>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
