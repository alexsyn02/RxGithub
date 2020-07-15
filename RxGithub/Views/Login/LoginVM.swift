//
//  LoginVM.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities

class LoginVM: VMInputOutputProtocol {
    
    struct Input {
        let username: Driver<String>
        let password: Driver<String>
        let onSignIn: Driver<()>
        let viewWillAppearSubject: Driver<()>
    }
    
    struct Output {
        let isLoading: Driver<Bool>
    }
    
    private let usernameRelay = BehaviorRelay<String>(value: "")
    private let passwordRelay = BehaviorRelay<String>(value: "")
    
    private let loader = ActivityIndicator()
    private var bag = DisposeBag()
    
    func transform(_ input: LoginVM.Input) -> LoginVM.Output {
        input.viewWillAppearSubject
            .map { _ in "" }
            .drive(passwordRelay)
            .disposed(by: bag)
        
        input.username
            .drive(usernameRelay)
            .disposed(by: bag)
        
        input.password
            .drive(passwordRelay)
            .disposed(by: bag)
        
        let user = input.onSignIn
            .withLatestFrom(Driver.combineLatest(usernameRelay.asDriver(), passwordRelay.asDriver()))
            .flatMap { [weak self] tuple -> Driver<User> in
                guard let self = self else { return .empty() }
                let (username, password) = tuple
                
                if !username.isEmpty && !password.isEmpty {
                    return GithubService.shared
                        .authorize(username: username, password: password)
                        .trackActivity(self.loader)
                        .asDriver(onErrorRecover: { (error) -> Driver<User> in
                            Router.shared.showAlert(error: error)
                            return .empty()
                        })
                } else {
                    Router.shared.showAlert(title: "Error", message: "Please enter valid credentials")
                    return .empty()
                }
        }
        
        user
            .drive(onNext: { [weak self] user in
                guard let self = self else { return }
                
                KeychainService.set(username: self.usernameRelay.value, password: self.passwordRelay.value)
                Router.shared.showRepositoryList()
            })
            .disposed(by: bag)
        
        return Output(isLoading: loader.asDriver())
    }
}
