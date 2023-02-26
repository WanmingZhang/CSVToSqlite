//
//  PSTintedButton.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import UIKit

class PSTintedButton: UIButton {
    override var isEnabled: Bool {
        didSet{
            if self.isEnabled {
                self.backgroundColor = UIColor.systemCyan
            }
            else{
                self.backgroundColor = UIColor.lightGray
            }
        }
    }

}

