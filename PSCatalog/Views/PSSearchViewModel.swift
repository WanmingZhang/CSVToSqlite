//
//  PSSearchViewModel.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

/// view model for search view controller
/// load database by natural sequence if not searching, support pagination by offset and limit
/// query database by user input, support pagination by offset and limit

class PSSearchViewModel {
    var products: Observable<[PSProduct]> = Observable([])
    var filtered: Observable<[PSProduct]> = Observable([])
    var errorMsg: Observable<String?> = Observable(nil)
    
    func loadProductsFromDatabase(_ limit: Int, _ offset: Int = 0) {
        self.filtered.value = []
        let db = ProductDataStore.shared
        let products = db.loadProductsFromDatabase(limit, offset)
        self.products.value = products
        print("load data from database \(self.products.value.count)")
    }
    
    func loadMoreFromDatabase(_ limit: Int, _ offset: Int) {
        let db = ProductDataStore.shared
        let products = db.loadProductsFromDatabase(limit, offset)
        self.products.value.append(contentsOf: products)
        print("load more data from database \(self.products.value.count)")
    }
    
    func queryDatabase(_ searchString: String, _ limit: Int, _ offset: Int = 0) {
        let db = ProductDataStore.shared
        guard !searchString.isEmpty else {
            return
        }
        let results = db.filterProducts(by: searchString, limit: limit, offset: offset)
        guard let filteredList = results.0 else {
            errorMsg.value = results.1?.localizedDescription
            return
        }
        print("filtered list: \(filteredList.count)")
        filtered.value = filteredList
    }
    
    func loadMoreQueryFromDatabase(_ searchString: String, _ limit: Int, _ offset: Int) {
        let db = ProductDataStore.shared
        guard !searchString.isEmpty else {
            return
        }
        let results = db.filterProducts(by: searchString, limit: limit, offset: offset)
        guard let moreFiltered = results.0 else {
            errorMsg.value = results.1?.localizedDescription
            return
        }
        self.filtered.value.append(contentsOf: moreFiltered)
        print("load more filtered data from database \(self.filtered.value.count)")
        
    }
}
