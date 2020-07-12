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
        let loadMoreRepositories: Driver<Bool>
        let repositorySelectedAt: Driver<IndexPath>
        let segmentedControlIndex: Driver<Int>
    }
    
    struct Output {
        let repositories: Driver<[RepositoryCellVM]>
        let isLoading: Driver<Bool>
    }
    
    private let repositoriesRelay = BehaviorRelay<[Repository]>(value: [])
    private let searchingPageRelay = BehaviorRelay<Int>(value: 1)
    private let searchQueryRelay = BehaviorRelay<String>(value: "")
    
    private let loader = ActivityIndicator()
    private var bag = DisposeBag()
    
    func transform(_ input: RepositoryListVM.Input) -> RepositoryListVM.Output {
        
        input.searchQuery
            .map { $0.count <= 30 ? $0 : "\($0[$0.startIndex..<$0.index($0.startIndex, offsetBy: 30)])" }
            .drive(onNext: { [weak self] searchQuery in
                self?.searchingPageRelay.accept(1)
                self?.searchQueryRelay.accept(searchQuery)
            })
            .disposed(by: bag)
        
        searchQueryRelay
            .asDriver(onErrorJustReturn: "")
            .filter { $0.isEmpty }
            .map { _ in [Repository]() }
            .drive(repositoriesRelay)
            .disposed(by: bag)
        
        let searchQuery = searchQueryRelay
            .skip(1)
            .asDriver(onErrorJustReturn: "")
            .filter { !$0.isEmpty }
        
        let firstResponse = searchQuery
            .withLatestFrom(searchingPageRelay.asDriver()) { ($0, $1) }
            .debounce(.seconds(1))
            .flatMap { [weak self] tuple -> Driver<[Repository]> in
                guard let self = self else { return .empty() }
                
                let (query, page) = tuple
                
                guard !query.isEmpty else { return .just([]) }
                
                return self.searchRepositories(query: query, page: page)
        }
        
        let secondResponse = searchQuery
            .withLatestFrom(searchingPageRelay.asDriver()) { ($0, $1) }
            .debounce(.seconds(1))
            .flatMap { [weak self] tuple -> Driver<[Repository]> in
                guard let self = self else { return .empty() }
                
                let (query, page) = tuple
                
                guard !query.isEmpty else { return .just([]) }
                
                return self.searchRepositories(query: query, page: page + 1)
        }
        
        input.loadMoreRepositories
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.searchingPageRelay.accept(self.searchingPageRelay.value + 2)
                self.searchQueryRelay.accept(self.searchQueryRelay.value)
                
            })
            .disposed(by: bag)
        
        let retrievedRepositories = Driver.combineLatest(firstResponse, secondResponse) { $0 + $1 }
        
        retrievedRepositories
            .withLatestFrom(Driver.combineLatest(repositoriesRelay.asDriver(), searchingPageRelay.asDriver())) { newRepositories, currentRepositoriesTuple in
                let (currentRepositories, page) = currentRepositoriesTuple
                
                return page == 0 ? newRepositories : (currentRepositories + newRepositories)
            }
            .drive(repositoriesRelay)
            .disposed(by: bag)
        
        let selectedRepository = input.repositorySelectedAt
            .withLatestFrom(repositoriesRelay.asDriver()) { $1[$0.row] }
        
        selectedRepository
            .drive(onNext: { repository in
                if let urlString = repository.htmlUrl, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url) { success in
                        if !success {
                            Router.shared.showAlert(error: CustomError.openURLError)
                        }
                    }
                }
            })
            .disposed(by: bag)
        
        let outputRepositories = repositoriesRelay
            .map { $0.map { RepositoryCellVM(repository: $0) } }
            .asDriver(onErrorJustReturn: [])
        
        return Output(repositories: outputRepositories,
                      isLoading: loader.asDriver())
    }
    
    private func searchRepositories(query: String, page: Int) -> Driver<[Repository]> {
        return GithubService.shared
            .searchRepositories(query: query, page: page)
            .trackActivity(self.loader)
            .asDriver { error in
                Router.shared.showAlert(error: error)
                return .empty()
        }
        .map { $0.items }
        .asSharedSequence()
    }
}
