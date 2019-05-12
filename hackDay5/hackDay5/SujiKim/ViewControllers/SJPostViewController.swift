//
//  SJPostViewController.swift
//  hackDay5
//
//  Created by Suji Kim on 30/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SJPostViewController: UIViewController {

    var url:String?
    var contentsListModel:ListModel?
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nicknameImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var writtenDateLabel: UILabel!
    @IBOutlet weak var edittedDateLabel: UILabel!
    
    @IBOutlet weak var detailContentsTableView: UITableView!
    
    private var detailContent:[SJDetailModel] = []
    private var edittedDate:Date?
    
    private let detailParser = SJHTMLPostParser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageViewCell = UINib(nibName: "SJImageTableViewCell", bundle: nil)
        detailContentsTableView.register(imageViewCell, forCellReuseIdentifier: "SJImageTableViewCell")
        
        let contentTextViewCell = UINib(nibName: "SJContentsTableViewCell", bundle: nil)
        detailContentsTableView.register(contentTextViewCell, forCellReuseIdentifier: "SJContentsTableViewCell")
        
        detailContentsTableView.allowsSelection = false
        detailContentsTableView.rowHeight = UITableViewAutomaticDimension
        detailContentsTableView.estimatedRowHeight = 44
        detailContentsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        if let urlString = url {
            self.setContentList(urlString)
        }
    }
}

// MARK: - SJPostViewController에서 필요한 functions
extension SJPostViewController {
    private func setView() {
        /* Comment
         contentsListModel가 self 의 프로퍼티라는 걸 명시적으로 써주시는게 좋을 것 같아요.
         setView()라는 네이밍도 모델의 값으로 뷰의 내용을 설정한다라는 의미로 보기가 어려운거 같아요.
         조금 더 이름 짓는 것에 대해서 고민해보셨으면 합니다.
         */
        if let contentsInfo = contentsListModel {
            self.categoryLabel.text = "[\(contentsInfo.category)]"
            self.titleLabel.text = contentsInfo.title
            self.writtenDateLabel.text = "작성일 : \(contentsInfo.date.convertDateToStringForPostPageDate())"
            if let textNickName = contentsInfo.nickNameModel.nickName {
                self.nicknameLabel.isHidden = false
                self.nicknameLabel.text = textNickName
                self.nicknameImageView.isHidden = true
            }
            else if let gifNickName = contentsInfo.nickNameModel.gifNickName {
                self.nicknameImageView.isHidden = false
                if let url = URL(string: gifNickName) {
                    self.nicknameImageView.contentMode = .scaleAspectFill
                    self.nicknameImageView.downloadImage(from: url)
                }
                self.nicknameLabel.isHidden = true
            }
        }
        
        if let editted = self.edittedDate {
            edittedDateLabel.text = "수정일 : \(editted.convertDateToStringForPostPageDate())"
        }
    }
    
    func setContentList(_ url:String) {
        if let url:URL = URL(string: url) {
            do {
                // URL을 활용해서
                let htmlString = try String(contentsOf: url, encoding: .utf8)
                let contents = detailParser.contentParser(htmlString)
                let editted = detailParser.getEditedDate(contents)
                self.edittedDate = editted.convertStringToDate()
                
                let link = detailParser.getAttachedLink(contents)
                var contentLink:SJDetailModel?
                if link != "" {
                    contentLink = SJDetailModel.init(type: "구매링크", content: link)
                }
                if let content = contentLink {
                    self.detailContent.append(content)
//                    print(content)
                }
                
                
                let bodyContents = detailParser.getContents(contents)
                for i in 0..<bodyContents.count {
                    self.detailContent.append(bodyContents[i])
                }
                
                /* Comment
                 뷰에 대한 요소들을 채워준 이후에 테이블뷰를 리로드하는게 나아보여요.
                 실제 테이블뷰를 리로드하는 코드는 self.setView() 내부에서 하는게 더 적절해보입니다.
                 */
                detailContentsTableView.reloadData()
                self.setView()
                
            } catch let e {
                // handle error
                print("😱😱😱\(e.localizedDescription)")
            }
        }
        
    }
}

// MARK: - UITableViewDelegate
extension SJPostViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            /* Comment
            이미지의 실제 크기에 따라서 높이가 가변이 되도록 하는 부분을 고민해보셨으면 합니다.
             */
            if detailContent[indexPath.row].type == "image" {
                return 200
            }
            else {
                return UITableViewAutomaticDimension
            }
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if detailContent[indexPath.row].type == "image" {
                return 200
            }
            else {
                return UITableViewAutomaticDimension
            }
        }
        else {
            return UITableViewAutomaticDimension
        }
    }
}

extension SJPostViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if detailContent[indexPath.row].type == "image" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"SJImageTableViewCell") as? SJImageTableViewCell else {
                return UITableViewCell()
            }
            cell.config(detailContent[indexPath.row].content)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"SJContentsTableViewCell") as? SJContentsTableViewCell else {
                return UITableViewCell()
            }
            cell.config(detailContent[indexPath.row])
            return cell
        }
    }
}
