//
//  SYPostViewController.swift
//  hackDay5
//
//  Created by sutie on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SYPostViewController: UIViewController {

    /* Comment
     SYListTableViewCell에서 가지고 있는 모델과 같은 형태라면,
     두개를 하나의 파일로 만들어서 같이 쓰는것이 괜찮을 것 같습니다.
     다른 형태라면,
     postListModel, postDetialModel 같은 형태로 나누어서 생성하는게 좋을것 같아요.
     */
    var post: ListModel! {
        didSet {
            titleLabel.text = post.title
            if let gifNickName = post.nickNameModel.gifNickName {
                nickNameImageView.isHidden = false
                nickNameLabel.isHidden = true
                nickNameImageView.image = downloadDataFrom(urlString: gifNickName)
            } else {
                nickNameImageView.isHidden = true
                nickNameLabel.isHidden = false
                nickNameLabel.text = post.nickNameModel.nickName
            }
            
            let totalURLString = "https://www.clien.net" + post.detailUrl
            guard let totalURL = URL(string: totalURLString) else {
                return
            }
            extractContents(url: totalURL)
        }
    }

    var detailModelArray: [DetailModel] = []
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var nickNameImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageCell = UINib(nibName: "SYImageViewTableViewCell", bundle: nil)
        let textViewCell = UINib(nibName: "SYTextViewTableViewCell", bundle: nil)
        
        tableView.register(imageCell, forCellReuseIdentifier: "SYImageViewTableViewCell")
        tableView.register(textViewCell, forCellReuseIdentifier: "SYTextViewTableViewCell")
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        let syMainVC = self.navigationController?.viewControllers[0] as! SYMainViewController
        syMainVC.tableView.reloadData()
    }

    // SYListTableViewCell에서도 사용됨..
    /* Comment
     다른 파일에서 말한 방법으로 모듈화 하면 좋을것 같습니다.
     */
    private func downloadDataFrom(urlString: String) -> UIImage? {
        guard let gifURL = URL(string: urlString) else {
            return nil
        }
        
        do {
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
    
    /* Comment
     다른 파일에서 말한 이니셜라이저를 통해서 생성하면 좋을것 같습니다.
     */
    static func create() -> SYPostViewController {
        if let vc = Bundle.main.loadNibNamed("SYPostViewController", owner: nil, options: nil)?.first as? SYPostViewController {
            return vc
        }
        return UIViewController() as! SYPostViewController
    }
}

/* Comment
 목록쪽과 이부분을 별도의 파싱 로직으로 분리하는게 좋을 것 같습니다.
 또한, contentsOf 보단 URLSession으로 구현해보시는게 좋아요.
 */
extension SYPostViewController {
    func extractContents(url: URL) {
        do {
            print(url.absoluteString)
            let contents = try String(contentsOf: url)
            let contentsLength = contents.utf16.count
            
            // Contents body 부분 추출
            let contentsReg = try NSRegularExpression(pattern: "(?<=<meta name=\"description\" content=\")([^\"]+)", options: .caseInsensitive)
            let matchedContents = contentsReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            let detailText = DetailModel.init(content: matchedContents, type: .text)
            detailModelArray.append(detailText)
            
            // 이미지 소스 파싱
            var matchedImage: [DetailModel]?
            if contents.contains("<img class=\"TOP fr-dib fr-fil fr-draggable") {
                // 상위에 이미지
                let imageReg = try NSRegularExpression(pattern: "(?<=<img class=\"TOP fr-dib fr-fil fr-draggable\" src=\")([^\"]+)", options: .caseInsensitive)
                let imageURL = imageReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                    .compactMap { Range($0.range, in: contents) }
                    .map { String(contents[$0]) }.first!

                let eachModel = DetailModel.init(content: imageURL, type: .image)
                detailModelArray.insert(eachModel, at: 0)
            }
            
            if contents.contains("<img class=\"fr-dib fr-fil\" src=\"") {
                let imageReg = try NSRegularExpression(pattern: "(?<=<img class=\"fr-dib fr-fil\" src=\")([^\"]+)", options: .caseInsensitive)
                matchedImage = imageReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                    .compactMap { Range($0.range, in: contents) }
                    .map { String(contents[$0]) }
                    .map { DetailModel.init(content: $0, type: .image) }
                
            } else if contents.contains("(?<=<img src=\").+(?=class=\"fr-fic fr-dii)") {
                let imageReg = try NSRegularExpression(pattern: "(?<=<img src=\").+(?=class=\"fr-fic fr-dii)", options: .caseInsensitive)
                matchedImage = imageReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                    .compactMap { Range($0.range, in: contents) }
                    .map { String(contents[$0]) }
                    .map { DetailModel.init(content: $0, type: .image) }
            }
            
            matchedImage?.forEach { detailModelArray.append($0) }

            tableView.reloadData()
            
        } catch {
            // error
            print(error)
        }
    }
}

extension SYPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailModelArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        
        if detailModelArray[section].type == .text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SYTextViewTableViewCell") as! SYTextViewTableViewCell
            cell.content = detailModelArray[indexPath.row + section].content
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SYImageViewTableViewCell") as! SYImageViewTableViewCell
            cell.contentImage = detailModelArray[indexPath.row + section].content
            return cell
        }
    }
    
}
