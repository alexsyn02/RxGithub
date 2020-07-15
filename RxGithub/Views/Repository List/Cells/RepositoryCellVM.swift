//
//  RepositoryCellVM.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class RepositoryCellVM: VMProtocol, IdentifiableType {
    private(set) var identity: Int
    
    var fullName: Driver<String> { fullNameRelay.asDriver() }
    var description: Driver<String> { descriptionRelay.asDriver() }
    var score: Driver<String> { scoreRelay.asDriver() }
    var isViewed: Driver<Bool> { isViewedRelay.asDriver() }
    var isLocal: Bool
    
    private let fullNameRelay: BehaviorRelay<String>
    private let descriptionRelay: BehaviorRelay<String>
    private let scoreRelay: BehaviorRelay<String>
    private let isViewedRelay: BehaviorRelay<Bool>
    
    init(repository: Repository) {
        identity = repository.id
        
        fullNameRelay = BehaviorRelay(value: repository.fullName ?? "")
        descriptionRelay = BehaviorRelay(value: repository.description ?? "")
        scoreRelay = BehaviorRelay(value: (repository.score ?? 0).twoDecimalsString)
        isViewedRelay = BehaviorRelay(value: repository.isViewed ?? false)
        isLocal = repository.isLocal ?? false
    }
}

extension RepositoryCellVM: Hashable {
    static func == (lhs: RepositoryCellVM, rhs: RepositoryCellVM) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
