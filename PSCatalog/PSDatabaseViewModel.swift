//
//  PSDatabaseViewModel.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

class PSDatabaseViewModel {
    var products: Observable<[PSProduct]> = Observable([])
    var errorMsg: Observable<String?> = Observable(nil)
    var progress: Observable<Float> = Observable(0)
    
    func parseFile() {
        let parser = PSCSVParser()
        guard let url = getFileURL() else {return}
        parser.parseCSV(contentsOfURL: url as NSURL, encoding: .utf8) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    guard let products = products else {
                        return
                    }
                    self.products.value = products
                    print("there are: \(products.count) products")
                case .failure(let error):
                    self.errorMsg.value = error.localizedDescription
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getFileURL() -> URL? {
        let fileService = PSFileService()
        let directoryUrl = fileService.getFileDestURL(directory: Constants.DIR_CATALOG, name: Constants.FILE_NAME)
        return directoryUrl
    }
    
    func loadDataIntoDB() {
        let db = ProductDataStore.shared
        var all = self.products.value
        guard !all.isEmpty else { return }
        all.removeFirst()
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            //let first20 = Array(all[0...17])
            
            for product in all {
                if let row = db.insert(productId: product.productId,
                                       title: product.title,
                                       listPrice: product.listPrice,
                                       salesPrice: product.salesPrice,
                                       color: product.color,
                                       size: product.size) {

                    self.progress.value = Float(row) / Float(all.count)
                    print("inserted at \(row), all = \(all.count), progress: \(self.progress.value)")
                }

            }

//            db.deleteAll()
//
//            let curr = db.getProducts()
//            print("... \(curr.count)...")
//            for p in curr {
//                print("\(p.productId); \(p.title); \(p.listPrice); \(p.salesPrice); \(p.color); \(p.size)")
//            }
        }
        
        
        
    }
}
