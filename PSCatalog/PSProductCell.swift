//
//  PSProductCell.swift
//  PSCatalog
//
//  Created by wanming zhang on 2/24/23.
//

import UIKit

class PSProductCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with product: PSProduct) {
        title.text = product.title
        color.text = product.color
        size.text = product.size
        price.text = "$ \(product.listPrice)"
    }

}
