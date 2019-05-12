//
//  SJListTableViewCell.swift
//  hackDay5
//
//  Created by Suji Kim on 30/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SJListTableViewCell: UITableViewCell {
    
//    var listContent:ListModel! {
//        didSet {
//            self.config()
//        }
//    }

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var nickNameImageView: UIImageView!
    
    private let defaultURL = "https://www.clien.net/service/board/jirum"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func config(_ listContent:ListModel) {
        categoryLabel.text = listContent.category
        titleLabel.text = listContent.title
        if listContent.isRead {
            titleLabel.textColor = UIColor.lightGray
        }
        else {
            titleLabel.textColor = UIColor.black
        }
        if listContent.likes != 0 {
            if let likeNumber = listContent.likes {
                likeLabel.isHidden = false
                likeLabel.text = "좋아요 \(likeNumber)"
            }
        }
        else {
            likeLabel.isHidden = true
        }
        viewCountLabel.text = "조회수 \(listContent.viewCnt)"
        dateLabel.text = listContent.date.convertDateToString()
        if let name = listContent.nickNameModel.nickName {
            nickNameImageView.isHidden = true
            nickNameLabel.isHidden = false
            nickNameLabel.text = name
        }
        else{
            nickNameLabel.isHidden = true
            nickNameImageView.isHidden = false
            if let urlString = listContent.nickNameModel.gifNickName, let url = URL(string: urlString) {
                nickNameImageView.contentMode = .scaleAspectFill
                nickNameImageView.downloadImage(from: url)
            }
        }
    }
}
