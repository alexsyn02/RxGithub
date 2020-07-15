//
//  VMView.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift

class VMView: XibLoadedView {
    var bag = DisposeBag()
    private var _viewModel: VMProtocol?
    
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
        subviews.forEach { ($0 as? VMView)?.unadvise() }
    }
    
    // called to bind needed for view
    func advise() {}
}
