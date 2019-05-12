//
//  SYTextViewTableViewCell.swift
//  hackDay5
//
//  Created by sutie on 30/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SYTextViewTableViewCell: UITableViewCell {
    
    var content: String! {
        didSet {
            self.textView.text = content
        }
    }

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
