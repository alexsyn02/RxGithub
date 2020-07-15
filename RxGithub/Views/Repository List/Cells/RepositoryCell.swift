//
//  ReporitoryCell.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 12.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

class RepositoryCell: VMTableCell {

    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var viewedLabel: UILabel!
    
    private var vm: RepositoryCellVM? { viewModel as? RepositoryCellVM }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func advise() {
        super.advise()
        
        vm?.fullName
            .drive(fullNameLabel.rx.text)
            .disposed(by: bag)
        
        vm?.description
            .drive(descriptionLabel.rx.text)
            .disposed(by: bag)
        
        vm?.score
            .drive(scoreLabel.rx.text)
            .disposed(by: bag)
        
        vm?.isViewed
            .map { !$0 }
            .drive(viewedLabel.rx.isHidden)
            .disposed(by: bag)
    }
}
