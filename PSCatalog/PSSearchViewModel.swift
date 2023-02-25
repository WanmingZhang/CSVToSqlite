//
//  PSSearchViewModel.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

class PSSearchViewModel {
    let limit = 20
    var products: Observable<[PSProduct]> = Observable([])
    var filtered: Observable<[PSProduct]> = Observable([])
    var errorMsg: Observable<String?> = Observable(nil)
    
    func loadProductsFromDatabase(_ offset: Int = 0, _ limit: Int) {
        let db = ProductDataStore.shared
        let products = db.loadProductsFromDatabase(offset, limit)
        self.products.value = products
        print("load data from database \(self.products.value.count)")
    }
    
    func loadMoreFromDatabase(_ offset: Int, _ limit: Int) {
        let db = ProductDataStore.shared
        let products = db.loadProductsFromDatabase(offset, limit)
        self.products.value.append(contentsOf: products)
        print("load more data from database \(self.products.value.count)")
    }
    
    func queryDatabase(_ searchString: String) {
        let db = ProductDataStore.shared
        guard !searchString.isEmpty else {
            return
        }
        let results = db.filterProducts(by: searchString)
        guard let products = results.0 else {
            errorMsg.value = results.1?.localizedDescription
            return
        }
        filtered.value = products
    }
}
