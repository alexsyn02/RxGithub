//
//  RepositoryListVM.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities

class RepositoryListVM: VMInputOutputProtocol {
    struct Input {
        let searchQuery: Driver<String>
        let segmentedControlIndex: Driver<Int>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
    }
    
    private let repositories = BehaviorRelay<[Repository]>(value: [])
    private let searchingPage = BehaviorRelay<Int>(value: 0)
    
    private let loader = ActivityIndicator()
    private var bag = DisposeBag()
    
    func transform(_ input: RepositoryListVM.Input) -> RepositoryListVM.Output {
        let firstResponse = input.searchQuery
            .debounce(.seconds(1))
            .flatMap { [weak self] query -> Driver<SearchRepositoriesResponse> in
                guard let self = self else { return .empty() }
                
                return GithubService.shared
                    .searchRepositories(query: query)
                    .trackActivity(self.loader)
                    .asDriver { error in
                        Router.shared.showAlert(error: error)
                        return .empty()
                    }
            }
            .map { $0.items }
        
        let secondResponse = input.searchQuery
            .debounce(.seconds(1))
            .flatMap { [weak self] query -> Driver<SearchRepositoriesResponse> in
                guard let self = self else { return .empty() }

                return GithubService.shared
                    .searchRepositories(query: query)
                    .trackActivity(self.loader)
                    .asDriver { error in
                        Router.shared.showAlert(error: error)
                        return .empty()
                    }
            }
            .map { $0.items }
        
        Driver.combineLatest(firstResponse, secondResponse) { $0 + $1 }
//            .withLatestFrom(repositories.asDriver()) { $1 + $0 }
            .drive(repositories)
            .disposed(by: bag)
        
        return Output(isLoading: loader.asDriver())
    }
}
