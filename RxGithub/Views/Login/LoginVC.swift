//
//  ViewController.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa

class LoginVC: VMVC {
    
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var signInButton: MainButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var vm: LoginVM { viewModel as! LoginVM }
    
    override static func instantiate() -> Self {
        return UIStoryboard.login.instantiateVC(with: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func bindViewModel() {
        let input = LoginVM.Input(username: usernameTextField.rx.text.orEmpty.asDriver(),
                                  password: passwordTextField.rx.text.orEmpty.asDriver(),
                                  onSignIn: signInButton.rx.tap.asDriver())
        
        let output = vm.transform(input)
        
        output.isLoading
            .map { !$0 }
            .drive(signInButton.rx.isEnabled)
            .disposed(by: bag)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
}
