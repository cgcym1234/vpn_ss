//
//  ConfigCell.swift
//  Lead
//
//  Created by yuany on 2019/3/11.
//  Copyright © 2019 yicheng. All rights reserved.
//

import UIKit
import Reusable

class ConfigCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var selectedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func render(with model: VPNManager.Config) -> ConfigCell {
        nameLabel.text = model.name
        selectedImageView.image = model.isSelected ? #imageLiteral(resourceName: "selected") : nil
        return self
    }
    
}

extension ConfigCell: Reusable {}
