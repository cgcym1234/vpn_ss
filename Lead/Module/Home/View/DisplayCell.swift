//
//  DisplayCell.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import UIKit
import Reusable

class DisplayCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func render(with model: String) -> DisplayCell {
        nameLabel.text = model
        
        return self
    }
}

extension DisplayCell: Reusable {}

