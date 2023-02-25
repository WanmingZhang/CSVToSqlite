//
//  PSSearchViewModel.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

class PSSearchViewModel {
    var filtered: Observable<[PSProduct]> = Observable([])
    var errorMsg: Observable<String?> = Observable(nil)
    
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
