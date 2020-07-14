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
        let cancelLoadMoreRepositories: Driver<()>
        let repositorySelectedAt: Driver<IndexPath>
        let selectedSearchType: Driver<SearchRepository.SearchType>
        let onLogout: Driver<()>
    }
    
    struct Output {
        let repositories: Driver<[RepositoryCellVM]>
        let isRepositoriesLoaded: Driver<()>
        let isLoading: Driver<Bool>
    }
    
    private let selectedSearchTypeRelay = BehaviorRelay<SearchRepository.SearchType>(value: .search)
    private let searchQueryRelay = BehaviorRelay<String>(value: "")
    private let searchingPageRelay = BehaviorRelay<Int>(value: 1)
    private let repositoriesRelay = BehaviorRelay<[Repository]>(value: [])
    
    private let loader = ActivityIndicator()
    private var bag = DisposeBag()
    
    private let realm = try! Realm()
    
    func transform(_ input: RepositoryListVM.Input) -> RepositoryListVM.Output {
        
        input.selectedSearchType
            .drive(selectedSearchTypeRelay)
            .disposed(by: bag)
        
        selectedSearchTypeRelay
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchingPageRelay.accept(1)
                self.searchQueryRelay.accept(self.searchQueryRelay.value)
            })
            .disposed(by: bag)
        
        input.cancelLoadMoreRepositories
            .drive(onNext: { _ in
                TasksService.shared.cancelAllRequests()
            })
            .disposed(by: bag)
        
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
            .withLatestFrom(selectedSearchTypeRelay.asDriver())
            .filter { $0 == .search }
            .map { _ in [Repository]() }
            .drive(repositoriesRelay)
            .disposed(by: bag)
        
        let searchQuery = searchQueryRelay
            .skip(1)
            .asDriver(onErrorJustReturn: "")
        
        let firstResponse = searchRepositories(searchQuery: searchQuery)
        let secondResponse = searchRepositories(searchQuery: searchQuery, isSecondRequest: true)
            
        input.loadMoreRepositories
            .withLatestFrom(selectedSearchTypeRelay.asDriver())
            .filter { $0 == .search }
            .drive(onNext: { [weak self] type in
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
            .withLatestFrom(selectedSearchTypeRelay.asDriver()) { [weak self] retrievedRepositories, selectedSearchType -> [Repository] in
                let viewedRepositories = self?.fetchRecentRepositories() ?? []
                
                if selectedSearchType == .search {
                    retrievedRepositories
                        .forEach { $0.isViewed = viewedRepositories.contains($0) }
                }
                
                return retrievedRepositories
        }
        
        retrievedRepositories
            .drive(onNext: { [weak self] repositories in
                repositories
                    .map { RepositoryRealm(repository: $0) }
                    .forEach { repository in
                        do {
                            try self?.realm.write {
                                if let localRepository = self?.realm.object(ofType: RepositoryRealm.self, forPrimaryKey: repository.id) {
                                    self?.realm.delete(localRepository)
                                }
                                self?.realm.add(repository)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                }
            })
            .disposed(by: bag)
        
        retrievedRepositories
            .withLatestFrom(Driver.combineLatest(repositoriesRelay.asDriver(), searchingPageRelay.asDriver(), selectedSearchTypeRelay.asDriver())) { newRepositories, currentRepositoriesTuple in
                let (currentRepositories, page, selectedSearchType) = currentRepositoriesTuple
                
                if page == 1 || selectedSearchType == .recent {
                    return newRepositories
                }
                
                return currentRepositories + newRepositories
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
    
    private func fetchRecentRepositories(predicate: NSPredicate? = nil) -> [Repository] {
        let repositories: Results<RepositoryRealm>
        
        if let predicate = predicate {
            repositories = realm.objects(RepositoryRealm.self)
                .filter(predicate)
        } else {
            repositories = realm.objects(RepositoryRealm.self)
        }
        
        return repositories
            .map { Repository(repositoryRealm: $0) }
    }
    
    private func searchRepositories(searchQuery: Driver<String>, isSecondRequest: Bool = false) -> Driver<[Repository]> {
        Driver.combineLatest(searchQuery, searchingPageRelay.asDriver(), selectedSearchTypeRelay.asDriver().distinctUntilChanged()) {
            SearchRepository(query: $0, page: $1, type: $2)
        }
        .debounce(.seconds(1))
        .flatMap { [weak self] model -> Driver<[Repository]> in
            guard let self = self else { return .empty() }
            
            print(model.type)
            
            if model.type == .recent {
                if isSecondRequest {
                    return .just([])
                } else {
                    let predicate: NSPredicate? = !model.query.isEmpty ? NSPredicate(format: "fullName contains %@", model.query) : nil
                    return .just(self.fetchRecentRepositories(predicate: predicate))
                }
            } else if model.query.isEmpty {
                return .just([])
            }
            
            return GithubService.shared
                .searchRepositories(query: model.query, page: !isSecondRequest ? model.page : (model.page + 1))
                .trackActivity(self.loader)
                .asDriver { error in
                    if (error as NSError).code != NSURLErrorCancelled {
                        Router.shared.showAlert(error: error)
                    }
                    return .empty()
            }
            .map { $0.items }
            .asSharedSequence()
        }
    }
}
