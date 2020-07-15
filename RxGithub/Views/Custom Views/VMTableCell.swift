//
//  VMTableCell.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift

class VMTableCell: UITableViewCell {

    var bag = DisposeBag()
    let didLoadSubject = ReplaySubject<Void>.create(bufferSize: 1)

    override func awakeFromNib() {
        super.awakeFromNib()
        didLoadSubject.onNext(())
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        unadvise()
        bag = DisposeBag()
        advise()
    }
    
    private var _viewModel: VMProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    // called to bind needed for cell
    func advise() {}
    
    // called to dispose binds needed for cell
    func unadvise() {
        bag = DisposeBag()
        subviews.forEach { ($0 as? VMView)?.unadvise() }
    }
}

