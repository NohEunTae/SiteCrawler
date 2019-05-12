//
//  SJContentsTableViewCell.swift
//  hackDay5
//
//  Created by Suji Kim on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SJContentsTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(_ data:SJDetailModel) {
        if data.type == "구매링크" {
            contentTextView.text = "구매링크 : \(data.content)"
            contentTextView.backgroundColor = UIColor.init(red: 151/255, green: 195/255, blue: 206/255, alpha: 1)
            contentTextView.layer.cornerRadius = 5
        }
        else {
            contentTextView.text = data.content
            contentTextView.backgroundColor = UIColor.white
        }
    }
    
}
