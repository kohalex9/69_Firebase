//
//  UserReviewTableViewCell.swift
//  1_SimpleFirebase
//
//  Created by Alex Koh on 07/09/2017.
//  Copyright © 2017 AlexKoh. All rights reserved.
//

import UIKit

class UserReviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
