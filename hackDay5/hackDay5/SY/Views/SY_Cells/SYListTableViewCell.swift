//
//  SYListTableViewCell.swift
//  hackDay5
//
//  Created by sutie on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SYListTableViewCell: UITableViewCell {

    var post: ListModel! {
        didSet {
            titleLabel.text = post.title
            if post.likes == 0 {
                likeStackView.isHidden = true
            } else {
                likeStackView.isHidden = false
                likeImageView.image = UIImage(named: "likeImage")
                likeCountLabel.text = String(post.likes!)
            }
            
            let formatter = DateFormatter()
            dateLabel.text = formatter.converToString(date: post.date)
            viewCountLabel.text = "조회수 " + post.viewCnt.formattedWithSeparator
            categoryLabel.text = post.category
            
            /* Comment
             post 라는 이름보다는 명확하게 Model임을 나타나낼수 있는 형태로 클래스를 나누는게 좋아보여요.
             MVVM이라는 패턴에서 현재 이 Cell은 View일거고, post는 ViewModel의 형태이기때문에요.
             
             위 처럼 했을때,
             또한 아래의 setNickName과 setTitleLabel은 Cell의 이니셜라이저를 구현해서
             post라는 ViewModel을 넘겨주는 형태가 가장 MVVM에 적합할거 같아요.
             */
            self.setNickName()
            self.setTitleLabel()
            self.layoutIfNeeded()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var likeStackView: UIStackView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var categoryContainerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var nickNameImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryContainerView.layer.cornerRadius = 10
    }
    
    private func setNickName() {
        if let nickName = post.nickNameModel.nickName {
            nickNameImageView.isHidden = true
            nickNameLabel.isHidden = false
            nickNameLabel.text = nickName
        } else {
            nickNameImageView.isHidden = false
            nickNameLabel.isHidden = true
            guard let gifURLString = post.nickNameModel.gifNickName else {
                return
            }
            nickNameImageView.image = downloadDataFrom(urlString: gifURLString)
        }
    }
    
    // 어떻게 모듈화시키면 좋을지 고민.... SYPostVC에서도 사용되기 때문
    /* Comment
     별도의 파일로 분리하는것이 가장 좋을거 같습니다.
     URLString을 넘겨주고, 클로저를 통해서 다운받은 이미지를 전달해주는 형태입니다.
     */
    private func downloadDataFrom(urlString: String) -> UIImage? {
        guard let gifURL = URL(string: urlString) else {
            return nil
        }
        
        do {
            /* Comment
             아래 부분은 사실 URLSession을 통해서 구현해보는게 더 좋을 것 같습니다.
             보통 Data에서 url로 값을 만드는건 로컬에 있는 파일에 접근할때, 빠르게 동작 할 수 있어요.
             일반적인 네트워크를 통해서 받아오는 데이터는 URLSession을 통해서 구현하는게 더 적합합니다.
             */
            let imageData = try Data(contentsOf: gifURL)
            guard let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        } catch {
            print(error)
        }
        return nil
    }
    
    private func setTitleLabel() {
        if post.isRead {
            titleLabel.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        } else {
            titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        if post.isSoldOut {
            titleLabel.setStrikeThrough()
            titleLabel.textColor = #colorLiteral(red: 0.9019607843, green: 0.7254901961, blue: 0.7647058824, alpha: 0.832807149)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
