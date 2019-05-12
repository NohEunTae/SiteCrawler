//
//  SJImageTableViewCell.swift
//  hackDay5
//
//  Created by Suji Kim on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SJImageTableViewCell: UITableViewCell {

    @IBOutlet weak var contentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ data:String) {
        if data != "" {
            if let url = URL(string: data) {
                contentImageView.contentMode = .scaleAspectFit
                contentImageView.downloadImage(from: url)
            }
        }
    }
}
