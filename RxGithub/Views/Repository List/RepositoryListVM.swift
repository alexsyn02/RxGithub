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
import RealmSwift

class RepositoryListVM: VMInputOutputProtocol {
    struct Input {
        let searchQuery: Driver<String>
        let loadMoreRepositories: Driver<()>
        let repositorySelectedAt: Driver<IndexPath>
        let segmentedControlIndex: Driver<Int>
        let onLogout: Driver<()>
    }
    
    struct Output {
        let repositories: Driver<[RepositoryCellVM]>
        let isRepositoriesLoaded: Driver<()>
        let isLoading: Driver<Bool>
    }
    
    private let repositoriesRelay = BehaviorRelay<[Repository]>(value: [])
    private let searchingPageRelay = BehaviorRelay<Int>(value: 1)
    private let searchQueryRelay = BehaviorRelay<String>(value: "")
    
    private let loader = ActivityIndicator()
    private var bag = DisposeBag()
    
    private let realm = try! Realm()
    
    func transform(_ input: RepositoryListVM.Input) -> RepositoryListVM.Output {
        
//        fetchRecentRepositories()
        
        input.searchQuery
            .map { $0.count <= 30 ? $0 : "\($0[$0.startIndex..<$0.index($0.startIndex, offsetBy: 30)])" }
            .drive(onNext: { [weak self] searchQuery in
                self?.searchingPageRelay.accept(1)
                self?.searchQueryRelay.accept(searchQuery)
            })
            .disposed(by: bag)
        
        searchQueryRelay
            .skip(1)
            .asDriver(onErrorJustReturn: "")
            .filter { $0.isEmpty }
            .map { _ in [Repository]() }
            .drive(repositoriesRelay)
            .disposed(by: bag)
        
        let searchQuery = searchQueryRelay
            .skip(1)
            .asDriver(onErrorJustReturn: "")
            .filter { !$0.isEmpty }
        
        let firstResponse = searchRepositories(searchQuery: searchQuery)
        let secondResponse = searchRepositories(searchQuery: searchQuery, isSecondRequest: true)
            
        input.loadMoreRepositories
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                print("load more with current search page: \(self.searchingPageRelay.value)")
                
                self.searchingPageRelay.accept(self.searchingPageRelay.value + 2)
                self.searchQueryRelay.accept(self.searchQueryRelay.value)
                
            })
            .disposed(by: bag)
        
        input.onLogout
            .drive(onNext: { _ in
                KeychainService.clear()
                Router.shared.pop()
            })
            .disposed(by: bag)
        
        let retrievedRepositories = Driver.zip(firstResponse, secondResponse) { $0 + $1 }
        
        retrievedRepositories
            .drive(onNext: { [weak self] repositories in
                let repositoriesRealm = repositories.map { RepositoryRealm(repository: $0) }
                
                do {
                    try self?.realm.write {
                        self?.realm.add(repositoriesRealm)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: bag)
        
        retrievedRepositories
            .withLatestFrom(Driver.combineLatest(repositoriesRelay.asDriver(), searchingPageRelay.asDriver())) { newRepositories, currentRepositoriesTuple in
                let (currentRepositories, page) = currentRepositoriesTuple
                
                return page == 0 ? newRepositories : (currentRepositories + newRepositories)
            }
            .drive(repositoriesRelay)
            .disposed(by: bag)
        
        let isRepositoriesLoaded = repositoriesRelay
            .asDriver()
            .map { _ in () }
        
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
                      isRepositoriesLoaded: isRepositoriesLoaded,
                      isLoading: loader.asDriver())
    }
    
    private func fetchRecentRepositories() {
        let localRepositories: [Repository] = realm.objects(RepositoryRealm.self)
            .map { Repository(repositoryRealm: $0) }
        repositoriesRelay.accept(localRepositories)
    }
    
    private func searchRepositories(searchQuery: Driver<String>, isSecondRequest: Bool = false) -> Driver<[Repository]> {
        searchQuery
            .withLatestFrom(searchingPageRelay.asDriver()) { ($0, $1) }
            .debounce(.seconds(1))
            .flatMap { [weak self] tuple -> Driver<[Repository]> in
                guard let self = self else { return .empty() }
                
                let (query, page) = tuple
                
                guard !query.isEmpty else { return .just([]) }
                
                return GithubService.shared
                    .searchRepositories(query: query, page: !isSecondRequest ? page : (page + 1))
                    .trackActivity(self.loader)
                    .asDriver { error in
                        Router.shared.showAlert(error: error)
                        return .empty()
                }
                .map { $0.items }
                .asSharedSequence()
        }
    }
}
