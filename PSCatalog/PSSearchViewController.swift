//
//  PSSearchViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import UIKit

class PSSearchViewController: UIViewController {
    var isLoading = false
    let viewModel: PSSearchViewModel
    let reuseCellId = "PSProductCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder: NSCoder) {
        let viewModel = PSSearchViewModel()
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search Database"
        configureTableView()
        callToViewModelToUpdateUI()
        setupBinder()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func callToViewModelToUpdateUI() {
        //viewModel.queryDatabase("white")
        viewModel.loadProductsFromDatabase(0, 5)
    }
    
    func setupBinder() {
        viewModel.products.bind {[weak self] products in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.viewModel.products.value.count > 0 else {
                    return
                }
                self.tableView.reloadData()
                self.isLoading = false
                
            }
        }

        viewModel.filtered.bind {[weak self] filtered in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard self.viewModel.filtered.value.count > 0 else {
                    return
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension PSSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("load table number of rows: \(viewModel.products.value.count)")
        return viewModel.products.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath) as? PSProductCell else {
            return cell
        }
        guard viewModel.products.value.count > 0 else {
            return cell
        }
        
        let product = viewModel.products.value[indexPath.row]
        productCell.update(with: product)
        return productCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // load more data
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let productCount = viewModel.products.value.count
        if productCount - 1 == indexPath.row && !isLoading {
            print("reached end of page: \(productCount)")
            loadMoreData(indexPath: indexPath)
        }
    }

    func loadMoreData(indexPath: IndexPath) {
        if !self.isLoading {
            self.isLoading = true
            viewModel.loadMoreFromDatabase(indexPath.row+1, 5)
            print("load more data offset: \(indexPath.row+1)")
        }
    }
    
    func loadMoreFiltered() {
        
    }
}
