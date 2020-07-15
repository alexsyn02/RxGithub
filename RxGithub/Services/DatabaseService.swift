//
//  DatabaseService.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 16.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation
import RealmSwift

class DatabaseService {
    static var realm: Realm {
        get {
            do {
                let realm = try Realm()
                return realm
            }
            catch {
                NSLog("Could not access database: ", error.localizedDescription)
            }
            return self.realm
        }
    }

    static func write(realm: Realm = realm, writeClosure: (Error?) -> ()) {
        do {
            try realm.write {
                writeClosure(nil)
            }
        } catch {
            writeClosure(error)
            NSLog("Could not access database: ", error.localizedDescription)
        }
    }
    
    static var repositoryListRealm: RepositoryArrayRealm? {
        realm.object(ofType: RepositoryArrayRealm.self, forPrimaryKey: 0)
    }
    
    static func add(repositories: [Repository]) {
        let retrievedRepositories = repositories.map { RepositoryRealm(repository: $0) }
        
        write { error in
            if error == nil {
                let repositoryList = RepositoryArrayRealm()
                
                if let list = DatabaseService.repositoryListRealm {
                    let currentRepositories = Array(list.repositories)
                        .filter { localRepository in !retrievedRepositories.contains(where: { localRepository.id == $0.id }) }
                    repositoryList.repositories.append(objectsIn: currentRepositories + retrievedRepositories)
                    realm.add(repositoryList, update: .modified)
                } else {
                    repositoryList.repositories.append(objectsIn: retrievedRepositories)
                    realm.create(RepositoryArrayRealm.self, value: repositoryList)
                }
            }
        }
    }
    
    static func deleteRepositoryWith(id: Int) {
        if let list = DatabaseService.repositoryListRealm, let repositoryIndexToDelete = list.repositories.firstIndex(where: { $0.id == id }) {
            write { error in
                if error == nil {
                    list.repositories.remove(at: repositoryIndexToDelete)
                }
            }
        }
    }
    
    static func swapRepositories(startIndex: Int, endIndex: Int) {
        if let list = repositoryListRealm {
            write { error in
                if error == nil {
                    list.repositories.swapAt(startIndex, endIndex)
                }
            }
        }
    }
}
