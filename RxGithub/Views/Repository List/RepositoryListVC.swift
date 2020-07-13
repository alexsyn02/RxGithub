//
//  RepositoryListVC.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa

class RepositoryListVC: VMVC {
    
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var vm: RepositoryListVM { viewModel as! RepositoryListVM }
    
    private let logoutSubject = PublishSubject<()>()
    private let isLoadingRepositoriesRelay = BehaviorRelay<Bool>(value: false)
    
    override static func instantiate() -> Self {
        return UIStoryboard.repositoryList.instantiateVC(with: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    private func configureViews() {
        let logOutBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutTapped(_:)))
        navigationItem.rightBarButtonItem = logOutBarButtonItem
        
        tableView.register(cellType: RepositoryCell.self)
        tableView.tableFooterView = UIView()
    }
    
    private func bindViewModel() {
        let query = searchTextField.rx
            .controlEvent(.editingChanged)
            .asDriver()
            .withLatestFrom(searchTextField.rx.text.orEmpty.asDriver())
        
        let itemSelected = tableView.rx.itemSelected
            .asDriver()
        
        itemSelected
            .drive(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
        
        Driver.combineLatest(tableView.rx.contentOffset.asDriver(), isLoadingRepositoriesRelay.asDriver())
            .filter { [weak self] offset, isLoading in
                let contentSizeHeight = (self?.tableView.contentSize ?? .zero).height
                
                guard !isLoading, contentSizeHeight > 0 else { return false }
                
                return offset.y >= contentSizeHeight / 2
        }
        .map { _ in true }
        .drive(isLoadingRepositoriesRelay)
        .disposed(by: bag)
        
        let loadMoreRepositories = isLoadingRepositoriesRelay
            .asDriver()
            .filter { $0 }
            .map { _ in () }
        
        let input = RepositoryListVM.Input(searchQuery: query,
                                           loadMoreRepositories: loadMoreRepositories,
                                           repositorySelectedAt: itemSelected,
                                           segmentedControlIndex: segmentedControl.rx.selectedSegmentIndex.asDriver(),
                                           onLogout: logoutSubject.asDriver(onErrorJustReturn: ()))
        
        let output = vm.transform(input)
        
        output.repositories
            .drive(tableView.rx.items(cellIdentifier: RepositoryCell.reuseIdentifier, cellType: RepositoryCell.self)) { _, model, cell in
                cell.viewModel = model
        }
        .disposed(by: bag)
        
        output.isRepositoriesLoaded
            .debounce(.milliseconds(500))
            .map { false }
            .drive(isLoadingRepositoriesRelay)
            .disposed(by: bag)
        
        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
    
    @objc
    private func logOutTapped(_ sender: UIBarButtonItem) {
        logoutSubject.onNext(())
    }
}
