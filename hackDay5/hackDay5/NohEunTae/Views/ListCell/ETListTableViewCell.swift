//
//  ETListTableViewCell.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var nickNameImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func modifyCell(with listModel: ListModel) {
        let gifFlag = (listModel.nickNameModel.gifNickName == nil)
        
        DispatchQueue.main.async {
            if gifFlag {
                self.nickNameImage.isHidden = true
                self.nickNameLabel.isHidden = false
                self.nickNameLabel.text = listModel.nickNameModel.nickName!
            } else {
                self.nickNameImage.isHidden = false
                self.nickNameLabel.isHidden = true
                if let url = listModel.nickNameModel.gifNickName, let validUrl = URL(string: url) {
                    self.downloadImage(from: validUrl)
                }
            }
            
            self.titleLabel.textColor = listModel.isSoldOut ? UIColor.orange : (listModel.isRead ? .lightGray : .black)

            if let likes = listModel.likes, likes != 0 {
                self.likesLabel.text = "\(likes)"
            } else {
                self.likesLabel.isHidden = true
            }
            
            self.viewCountLabel.text = "\(listModel.viewCnt)"
            self.titleLabel.text = listModel.title
            self.categoryLabel.text = listModel.category
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MM-dd"
            self.dateLabel.text = dateFormatterPrint.string(from: listModel.date)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.nickNameImage.image = UIImage(data: data)
            }
        }
    }
}
