//
//  RepositoryCellVM.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa

class RepositoryCellVM: VMProtocol {
    
    var fullName: Driver<String> { fullNameRelay.asDriver() }
    var description: Driver<String> { descriptionRelay.asDriver() }
    var score: Driver<String> { scoreRelay.asDriver() }
    var isViewed: Driver<Bool> { isViewedRelay.asDriver() }
    
    private let fullNameRelay: BehaviorRelay<String>
    private let descriptionRelay: BehaviorRelay<String>
    private let scoreRelay: BehaviorRelay<String>
    private let isViewedRelay: BehaviorRelay<Bool>
    
    init(repository: Repository) {
        fullNameRelay = BehaviorRelay(value: repository.fullName ?? "")
        descriptionRelay = BehaviorRelay(value: repository.description ?? "")
        scoreRelay = BehaviorRelay(value: (repository.score ?? 0).twoDecimalsString)
        isViewedRelay = BehaviorRelay(value: repository.isViewed ?? false)
    }
}
