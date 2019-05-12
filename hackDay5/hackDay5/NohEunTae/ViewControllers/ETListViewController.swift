//
//  ETListViewController.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    var lists: [ListModel] = [ListModel]()
    // 클리앙 알뜰구매 URL
    final let url = "https://www.clien.net/service/board/jirum?&od=T31&po="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableView()
        self.request(urlPath: url+"0")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.listTableView.reloadData()
    }
    
    // tableView 설정
    func setTableView() {
        let nibCell = UINib(nibName: "ETListTableViewCell", bundle: nil)
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        self.listTableView.register(nibCell, forCellReuseIdentifier: "ETListTableViewCell")
        self.listTableView.estimatedRowHeight = 60
        self.listTableView.rowHeight = UITableViewAutomaticDimension
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
        htmlParser.startParsing(line: dataString, parsingType: .list)
        htmlParser.startParsing(line: dataString, parsingType: .title)
    }
}

// Mark: - List Parsing Finished

extension ETListViewController: ETHtmlParserDelegate {

    func finishedParsing<T>(result: T, parsingType: ETParsingType) {
        switch parsingType {
        case .title:
            if let title = result as? String {
                DispatchQueue.main.async {
                    self.navigationController?.navigationBar.topItem?.title = title
                }
            }
        case .list:
            if let lists = result as? [ListModel] {
                for list in lists {
                    self.lists.append(list)
                }
                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                }
            }
            break
        default:
            break
        }
    }
}


// MARK: - List TableView Delegate

extension ETListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = self.lists[indexPath.row].detailUrl

        UserDefaults.standard.set(true, forKey: url)
        UserDefaults.standard.synchronize()
        
        self.lists[indexPath.row].isRead = true
        let etDetailViewController = ETDetailViewController(url: url, listModel: self.lists[indexPath.row])
        self.navigationController?.pushViewController(etDetailViewController, animated: true)
    }
}

// MARK: - List TableView DataSource

extension ETListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ETListTableViewCell", for: indexPath) as! ETListTableViewCell
        cell.modifyCell(with: self.lists[indexPath.row])
        cell.titleLabel.sizeToFit()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.lists.count - 5 {
            self.request(urlPath: self.url+"\(self.lists.count / 30)")
        }
    }
}

extension ETListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {        
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if (actualPosition.y > 0){
            // Dragging down
            DispatchQueue.main.async {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }else{
            // Dragging up
            DispatchQueue.main.async {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        }
    }
}
