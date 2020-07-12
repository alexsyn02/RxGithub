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
    
    private var vm: RepositoryListVM { viewModel as! RepositoryListVM }
    
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
    }
    
    private func bindViewModel() {
        let query = searchTextField.rx
            .controlEvent(.editingChanged)
            .asDriver()
            .withLatestFrom(searchTextField.rx.text.orEmpty.asDriver())
        
        let input = RepositoryListVM.Input(searchQuery: query,
                                           segmentedControlIndex: segmentedControl.rx.selectedSegmentIndex.asDriver())
        
        let output = vm.transform(input)
    }
    
    @objc
    private func logOutTapped(_ sender: UIBarButtonItem) {
        Router.shared.pop()
    }
}
