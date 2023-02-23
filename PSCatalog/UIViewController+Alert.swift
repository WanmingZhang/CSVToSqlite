//
//  UIViewController+Alert.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/23/23.
//

import UIKit

extension UIViewController {
    /**
     func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (Int) -> Void) {
         let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
         for (index, option) in options.enumerated() {
             alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                 completion(index)
             }))
         }
         self.present(alertController, animated: true, completion: nil)
     }
     */

    func presentAlertWithTitle(title: String, message: String, options: String..., completion: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, option) in options.enumerated() {
            alertController.addAction(UIAlertAction.init(title: option, style: .default, handler: { (action) in
                completion(options[index])
            }))
        }
        self.present(alertController, animated: true, completion: nil)
    }
}
