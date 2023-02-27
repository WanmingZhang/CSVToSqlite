//
//  PSSearchViewController.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import UIKit

class PSSearchViewController: UIViewController {
    var isLoading = false
    var isLoadingFiltered = false
    let viewModel: PSSearchViewModel
    let reuseCellId = "PSProductCell"
    let limit = 10
    @IBOutlet weak var tableView: UITableView!
    
    // search controller
    let searchController = UISearchController(searchResultsController: nil)
    var isFiltering: Bool {
        let isSearchBarEmpty = searchController.searchBar.text?.isEmpty ?? true
        return searchController.isActive && !isSearchBarEmpty
    }
    
    required init?(coder: NSCoder) {
        let viewModel = PSSearchViewModel()
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search Database"
        configureTableView()
        loadProductsFromDatabase()
        setupBinder()
        configureSearchBar()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadProductsFromDatabase() {
        viewModel.loadProductsFromDatabase(limit, 0)
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
                self.isLoadingFiltered = false
            }
        }
        
        viewModel.errorMsg.bind {[weak self] desc in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                print("search database error: \(desc ?? "")")
            }
        }
    }
    
    func configureSearchBar() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name, color, or size"
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.returnKeyType = .done
        navigationItem.searchController = searchController
    }
}

extension PSSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return viewModel.filtered.value.count
        } else {
            print("load table number of rows: \(viewModel.products.value.count)")
            return viewModel.products.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: reuseCellId, for: indexPath) as? PSProductCell else {
            return cell
        }
        if isFiltering {
            guard viewModel.filtered.value.count > 0 else {
                return cell
            }
            let product = viewModel.filtered.value[indexPath.row]
            productCell.update(with: product)
            return productCell
        } else {
            guard viewModel.products.value.count > 0 else {
                return cell
            }
            let product = viewModel.products.value[indexPath.row]
            productCell.update(with: product)
            return productCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFiltering {
            let count = viewModel.filtered.value.count
            if count - 1 == indexPath.row && !isLoadingFiltered {
                print("reached end of page: \(count)")
                loadMoreFiltered(indexPath: indexPath)
            }
        } else {
            let productCount = viewModel.products.value.count
            if productCount - 1 == indexPath.row && !isLoading {
                print("reached end of page: \(productCount)")
                loadMoreData(indexPath: indexPath)
            }
        }
    }
    // load more data
    func loadMoreData(indexPath: IndexPath) {
        if !self.isLoading {
            self.isLoading = true
            viewModel.loadMoreFromDatabase(limit, indexPath.row+1)
            print("load more data offset: \(indexPath.row+1)")
        }
    }
    
    // load more search result
    func loadMoreFiltered(indexPath: IndexPath) {
        if !self.isLoadingFiltered {
            self.isLoadingFiltered = true
            viewModel.loadMoreQueryFromDatabase(searchController.searchBar.text ?? "", limit, indexPath.row+1)
            print("load more filtered offset: \(indexPath.row+1)")
        }
    }
}

// MARK: search
extension PSSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.queryDatabase(text, limit, 0)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        loadProductsFromDatabase()
    }
}

