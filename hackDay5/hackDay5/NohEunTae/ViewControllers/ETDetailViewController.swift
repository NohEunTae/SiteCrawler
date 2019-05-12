//
//  ETDetailViewController.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit


// section type
enum Section: Int {
    case head = 0
    case body = 1
}

class ETDetailViewController: UIViewController {
    
    @IBOutlet weak var detailTableView: UITableView!
    
    var url: String = String()
    
    var headModel: ETDetailHeadModel?
    var listModel: ListModel?
    var bodyModel: [ETDetailBodyModel] = [ETDetailBodyModel]()
    
    private var contentTitle = String()

    init(url: String, listModel: ListModel) {
        self.url = url
        self.listModel = listModel
        super.init(nibName: "ETDetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setListTableView()
        self.request(urlPath: self.url)
    }
    
    func setListTableView() {
        let textNib = UINib(nibName: "ETDetailBodyTextTableViewCell", bundle: nil)
        let imageNib = UINib(nibName: "ETDetailBodyImageTableViewCell", bundle: nil)
        let headNib = UINib(nibName: "ETDetailHeadTableViewCell", bundle: nil)
        
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        
        self.detailTableView.register(textNib, forCellReuseIdentifier: "ETDetailBodyTextTableViewCell")
        self.detailTableView.register(imageNib, forCellReuseIdentifier: "ETDetailBodyImageTableViewCell")
        self.detailTableView.register(headNib, forCellReuseIdentifier: "ETDetailHeadTableViewCell")
        
        self.detailTableView.allowsSelection = false
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.estimatedRowHeight = 100
        self.detailTableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    // url을 통한 request 요청
    func request(urlPath: String) {
        ETNetwork.request(urlPath: urlPath) { (success, result) in
            switch success {
            case .success:
                print("[info] request sucess ... \(self.classForCoder)")
                if let result = result {
                    self.parse(dataString: result)
                }
                break
            case .failed:
                // load cashing data
                break
            }
        }
    }
    
    // request를 통해 받은 string data를 파싱
    func parse(dataString: String) {
        let htmlParser: ETHtmlParser = ETHtmlParser()
        htmlParser.delegate = self
        htmlParser.startParsing(line: dataString, parsingType: .detailBody)
        htmlParser.startParsing(line: dataString, parsingType: .detailHead)
        htmlParser.startParsing(line: dataString, parsingType: .title)
    }
}

// Mark: - Detail Parsing Finished

extension ETDetailViewController: ETHtmlParserDelegate {
    /* Comment
     구조적인 이슈이긴 하지만, 각 타입별 파싱이 별도로 이루어짐으로써,
     detailHead, detailBody 결과가 전달 될때마다, 테이블뷰가 다시 로드되는데요.
     이건 어떤 방식이 좋을지 다시한번 생각해보는게 좋을거 같아요.

     파서 내부에서 각 파싱타입별로 결과값을 전달받고, 모든 파싱이 완료되면 한번에 전달되는 형태로는 불가능할지도 고민해봤으면 좋겠습니다.
     */
    func finishedParsing<T>(result: T, parsingType: ETParsingType) {
        switch parsingType {
        case .title:
            if let title = result as? String {
                self.contentTitle = title

            }
            break
        case .detailHead:
            if let head = result as? String, let listModel = self.listModel {
                self.headModel = ETDetailHeadModel(listModel: listModel, topAttachLink: head)
            } else if let listModel = self.listModel {
                self.headModel = ETDetailHeadModel(listModel: listModel, topAttachLink: nil)
            }
            
            DispatchQueue.main.async {
                self.detailTableView.reloadData()
            }

            break
        case .detailBody:
            if let list = result as? [ETDetailBodyModel] {
                self.bodyModel = list
                DispatchQueue.main.async {
                    self.detailTableView.reloadData()
                }
            }
            break
        default:
            break
        }
    }
}


// MARK: - Detail TableView Delegate

extension ETDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 147
        default:
            let modelType = self.bodyModel[indexPath.row].modelType
            if let modelType = modelType {
                if modelType == .image {
                    return 200
                }
            }
            return UITableViewAutomaticDimension
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case Section.head.rawValue:
            return 147
        default:
            let modelType = bodyModel[indexPath.row].modelType
            if let modelType = modelType {
                if modelType == .image {
                    return 200
                }
            }
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: - Detail TableView Datasource

extension ETDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.head.rawValue:
            return (self.headModel == nil) ? 0 : 1
        case Section.body.rawValue:
            return self.bodyModel.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ETDetailHeadTableViewCell", for: indexPath) as! ETDetailHeadTableViewCell
            if let headModel = self.headModel {
                cell.modifyCell(with: headModel)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.topAttachLinkClicked(tap: )))
                cell.topLinkLabel.addGestureRecognizer(tap)                
                return cell
            }
        default:
            if let modelType = bodyModel[indexPath.row].modelType {
                switch modelType {
                case .image:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ETDetailBodyImageTableViewCell", for: indexPath) as! ETDetailBodyImageTableViewCell
                    if let url = URL(string: self.bodyModel[indexPath.row].content) {
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapImage(tap: )))
                        tap.name = self.bodyModel[indexPath.row].content // tag이름을 이미지 url로 설정
                        cell.downloadImage(from: url)
                        cell.infoImageView.addGestureRecognizer(tap)
                        return cell
                    }
                    break
                case .string:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ETDetailBodyTextTableViewCell", for: indexPath) as! ETDetailBodyTextTableViewCell
                    cell.textView.text = self.bodyModel[indexPath.row].content
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = (self.headModel == nil) ? 0 : 1
        return self.bodyModel.count + count
    }
    
    @objc func topAttachLinkClicked(tap: UITapGestureRecognizer) {
        guard let urlPath = self.headModel?.topAttachLink, let validUrl = URL(string: urlPath) else {
            return
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(validUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(validUrl)
        }
    }
    
    @objc func tapImage(tap: UITapGestureRecognizer) {
        if let selectedImageUrl = tap.name {
            // 모든 이미지 URL을 찾아온다
            let images = self.bodyModel.filter { $0.modelType == .image }.map { $0.content }
            
            // pagingViewController를 모든 이미지 URL과, 선택된 이미지 URL을 통해 생성함으로써 올바른 순서로 Paging ViewController 설정
            let pagingViewController = ETImagePagingViewController(imageUrls: images, selectedUrl: selectedImageUrl)

            self.view.backgroundColor = .black
            self.navigationController?.navigationBar.isHidden = true
            self.tabBarController?.tabBar.isHidden = true
            self.tabBarController?.tabBar.isTranslucent = true
            self.navigationController?.pushViewController(pagingViewController, animated: true)
        }
    }
}


// MARK: - Detail ViewController Scroll View Delegate

extension ETDetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // 상단에 위치하면 타이틀 ""
        if targetContentOffset.pointee.y == 0 {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.title = ""
            }
        }
        // 상단이 아닐경우 타이틀 설정
        else {
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.topItem?.title = self.contentTitle
            }
        }
    }
}
