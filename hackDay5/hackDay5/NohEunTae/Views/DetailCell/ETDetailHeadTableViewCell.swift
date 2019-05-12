//
//  ETDetailHeadTableViewCell.swift
//  hackDay5
//
//  Created by user on 2018. 11. 30..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETDetailHeadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var nickNameImage: UIImageView!
    @IBOutlet weak var topLinkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func modifyCell(with headModel: ETDetailHeadModel) {
        let gifFlag = (headModel.listModel.nickNameModel.gifNickName == nil)
        
        /* Comment
         cell의 데이터가 변경된다면, 마지막에 setNeedsLayout을 호출!
         */
        
        DispatchQueue.main.async {
            if gifFlag {
                self.nickNameImage.isHidden = true
                self.nickNameLabel.text = headModel.listModel.nickNameModel.nickName!
            } else {
                self.nickNameLabel.isHidden = true
                if let url = headModel.listModel.nickNameModel.gifNickName, let validUrl = URL(string: url) {
                    self.downloadImage(from: validUrl)
                }
            }
            
            if let likes = headModel.listModel.likes, likes != 0 {
                self.likesLabel.text = "\(likes)"
                self.likesLabel.isHidden = false
            } else {
                self.likesLabel.isHidden = true
            }

            if let topLink = headModel.topAttachLink {
                self.topLinkLabel.text = "\(topLink)"
            } else {
                self.topLinkLabel.isHidden = true
            }
            self.viewCountLabel.text = "\(headModel.listModel.viewCnt)"
            self.titleTextView.text = headModel.listModel.title
            self.categoryLabel.text = headModel.listModel.category
            self.dateLabel.text = "\(headModel.listModel.date)"
        }
    }
    
    /* Comment
     cell마다 아래 네트워크 통신부분이 있는거 같은데,
     그렇다면 별도의 extension으로 빼놓고 사용하는게 좋을것 같습니다.
     */
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                self.nickNameImage.image = UIImage(data: data)
            }
        }
    }
}
