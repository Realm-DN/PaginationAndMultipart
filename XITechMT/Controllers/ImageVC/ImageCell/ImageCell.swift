//
//  ImageCell.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import UIKit

class ImageCell: UITableViewCell {
    @IBOutlet weak var imgMain: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgMain.layer.cornerRadius = 12
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
