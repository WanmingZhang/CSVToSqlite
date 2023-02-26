//
//  Constants.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/23/23.
//

import Foundation

struct Constants {
    /// URL of the catalog file to be downloaded
    static let CATALOG_FILE_URL = "https://drive.google.com/uc?id=16jxfVYEM04175AMneRlT0EKtaDhhdrrv&export=download"
    /// a sub directory under  the Library/Caches directory
    static let DIR_CATALOG : String = "ProductCatalog"
    /// name of the catalog file
    static let FILE_NAME: String = "prod1M"
    
    static let DIR_Product_DB = "ProductDB"
    static let STORE_NAME = "product.sqlite3"
}
