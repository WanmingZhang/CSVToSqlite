//
//  Observable.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import Foundation

/**
 * helper class for binding of views and view models.
 * class is initialized with the value we want to observe.
 * function bind that does the binding.
 * observer is our closure called when the value is set.
 */

class Observable<T> {
    var value: T {
        didSet {
            observer?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    var observer: ((T) -> Void)?
    
    func bind(closure: @escaping (T) -> Void) {
        closure(value)
        observer = closure
    }
}
