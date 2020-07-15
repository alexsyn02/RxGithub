//
//  RepositoryListVC.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

class RepositoryListVC: VMVC {
    
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var cancelRepositoryRetrievingButton: UIButton!
    
    private var vm: RepositoryListVM { viewModel as! RepositoryListVM }
    
    private let isLoadingRepositoriesRelay = BehaviorRelay<Bool>(value: false)
    private let deleteLocalRepositoryIndexPathSubject = PublishSubject<IndexPath>()
    private let logoutSubject = PublishSubject<()>()
    
    private var canEditRowAtIndexPath: TableViewSectionedDataSource<AnimatableSectionModel<String, RepositoryCellVM>>.CanEditRowAtIndexPath { { $0.sectionModels[$1.section].items[$1.row].isLocal } }
    
    private var canMoveRowAtIndexPath: TableViewSectionedDataSource<AnimatableSectionModel<String, RepositoryCellVM>>.CanMoveRowAtIndexPath { { [weak self] in (self?.tableView.isEditing ?? false) && $0.sectionModels[$1.section].items[$1.row].isLocal } }
    
    private lazy var dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, RepositoryCellVM>>(configureCell: { dataSource, tableView, indexPath, viewModel in
        let cell = tableView.dequeueReusableCell(withType: RepositoryCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }, canEditRowAtIndexPath: canEditRowAtIndexPath,
       canMoveRowAtIndexPath: canMoveRowAtIndexPath)
    
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
        tableView.rx.setDelegate(self)
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
        
        let query = searchTextField.rx
            .controlEvent(.editingChanged)
            .asDriver()
            .withLatestFrom(searchTextField.rx.text.orEmpty.asDriver())
        
        let loadMoreRepositories = isLoadingRepositoriesRelay
            .asDriver()
            .filter { $0 }
            .map { _ in () }
        
        let itemSelected = tableView.rx.itemSelected
            .asDriver()
        
        itemSelected
            .drive(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
        
        let selectedSearchType = segmentedControl.rx
            .selectedSegmentIndex
            .asDriver()
            .map { SearchRepository.SearchType(rawValue: $0)! }
        
        selectedSearchType
            .drive(onNext: { [weak self] selectedSearchType in
                switch selectedSearchType {
                case .search:
                    self?.tableView.isEditing = false
                case .recent:
                    self?.tableView.isEditing = true
                }
            })
            .disposed(by: bag)
        
        let input = RepositoryListVM.Input(searchQuery: query,
                                           loadMoreRepositories: loadMoreRepositories,
                                           cancelLoadMoreRepositories: cancelRepositoryRetrievingButton.rx.tap.asDriver(),
                                           repositorySelectedAt: itemSelected,
                                           selectedSearchType: selectedSearchType,
                                           deletedLocalRepositoryIndexPath: deleteLocalRepositoryIndexPathSubject.asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0)),
                                           repositoryMoved: tableView.rx.itemMoved.asDriver(),
                                           onLogout: logoutSubject.asDriver(onErrorJustReturn: ()))
        
        let output = vm.transform(input)
        
        output.repositories
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        output.isRepositoriesLoaded
            .debounce(.milliseconds(500))
            .map { false }
            .drive(isLoadingRepositoriesRelay)
            .disposed(by: bag)
        
        output.isLoading
            .map { !$0 }
            .drive(cancelRepositoryRetrievingButton.rx.isHidden)
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

extension RepositoryListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            self?.deleteLocalRepositoryIndexPathSubject.onNext(indexPath)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
