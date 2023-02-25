//
//  PSSearchViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import UIKit

class PSSearchViewController: UIViewController {
    let viewModel: PSSearchViewModel
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder: NSCoder) {
        let viewModel = PSSearchViewModel()
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.queryDatabase("white")
        setupBinder()
    }
    
    func setupBinder() {
        viewModel.filtered.bind {[weak self] filtered in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.viewModel.filtered.value.count > 0 else {
                    return
                }
                print("*** filtered result: \(filtered.count)")
            }
        }
    }
    

}
