//
//  VMVC.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift

class VMVC: UIViewController {
    
    private var _viewModel: VMProtocol?
    
    var bag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func instantiate() -> Self {
        fatalError("Should be overrided")
    }
    
    var viewModel: VMProtocol? {
        get {
            return _viewModel
        }
        set(newViewModel) {
            if _viewModel !== newViewModel {
                unadvise()
                _viewModel = newViewModel
                if _viewModel != nil {
                    advise()
                }
            }
        }
    }
    
    deinit {
        viewModel = nil
    }
    
    // called to dispose binds needed for view
    func unadvise() {
        bag = DisposeBag()
    }
    
    // called to bind needed for view
    func advise() {
        bag = DisposeBag()
    }
}


