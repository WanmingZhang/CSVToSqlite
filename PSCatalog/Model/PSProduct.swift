//
//  PSProduct.swift
//  PSProduct
//
//  Created by wanming zhang on 2/23/23.
//

import Foundation

struct PSProduct {
    var productId: String
    var title: String
    var listPrice: Double
    var salesPrice: Double
    var color: String
    var size: String
    
    init(productId: String, title: String, listPrice: Double, salesPrice: Double, color: String, size: String) {
        self.productId = productId
        self.title = title
        self.listPrice = listPrice
        self.salesPrice = salesPrice
        self.color = color
        self.size = size
    }
}
