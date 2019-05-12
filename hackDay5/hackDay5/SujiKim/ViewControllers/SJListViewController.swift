//
//  SJListViewController.swift
//  hackDay5
//
//  Created by Suji Kim on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

class SJListViewController: UIViewController {

    private let defaultURL = "https://www.clien.net"
    private let parser = SJHTMLParser()
    var startTime = CFAbsoluteTimeGetCurrent()

    
    @IBOutlet weak var listTableView: UITableView!
    
    private var paging:Int = 0
    private var contentsList:[ListModel] = [ListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "SJListTableViewCell", bundle: nil)
//        self.listTableView.register(SJListTableViewCell.self, forCellReuseIdentifier: "SJListTableViewCell")
        self.listTableView.register(cellNib, forCellReuseIdentifier: "SJListTableViewCell")
        
        self.setContentsList("\(paging)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        listTableView.reloadData()
    }
    
    /* Comment
     function의 이름이 실제 목록을 요청하는 부분이다. 라는것을 명확히 전달하는 형태의 이름을 짓는게 중요합니다.
     set~~ , get~~ 형태는 실제 프로퍼티에 값을 셋팅하거나 꺼내오는 getter, setter 의 prefix이기때문에 지양하는 것이 좋아요.
     ex) requestContentList() 혹은 setupContentList() 같은 형태..
     */
    func setContentsList(_ page:String) {
        if let url:URL = URL(string: defaultURL + "/service/board/jirum?&od=T31&po=" + page) {
            do {
                // URL을 활용해서
                
                let htmlString = try String(contentsOf: url, encoding: .utf8)
                let contents = parser.contentListParser(htmlString)
                let titles = parser.getTitle(contents)
                let detailURLs = parser.getDetailURL(contents)
                let likes = parser.getLikes(contents)
                let dates = parser.getDate(contents)
                let viewCounts = parser.getViewCount(contents)
                let nicknames = parser.getNickName(contents)
                let categories = parser.getCategory(contents)
                
                var content:ListModel?
                for i in 0..<titles.count {
                    let likeString = likes[i].split(separator: " ")
                    content = ListModel.init(detailUrl: detailURLs[i], category: categories[i], title: titles[i], nickNameModel: setNickName(nicknames[i]), date: dates[i].convertStringToDate(), likes: Int(likeString[0]) , viewCnt: viewCounts[i].convertStringToInt(), isRead: false, isSoldOut: false)
                    self.contentsList.append(content!)
                    
                    /* Comment
                     - DataSource에 항목을 추가할때마다 리로드 요청을 하는 부분이 효율적으로 보이진 않습니다.
                     아마 흰화면이 나온 이후에 목록이 불러와지는 이유가 이 부분때문인것 같아요.
                     self.contentsList에 모든 항목을 추가한 후에, 테이블뷰 리로드를 한번만 호출해야할 것 같아요.
                     */
                }
                
                let processTime = CFAbsoluteTimeGetCurrent() - self.startTime
                print("sj 수행 시간 = \(processTime)")

                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                }
            } catch let e {
                // handle error
                print("😱😱😱\(e.localizedDescription)")
            }
        }
        
    }
    
    func setNickName(_ nickName:String) -> NickNameModel {
        if nickName.hasPrefix("http") {
            let nickNameModel = NickNameModel.init(nickName: nil, gifNickName: nickName)
            return nickNameModel
        }
        else {
            let nickNameModel = NickNameModel.init(nickName: nickName, gifNickName: nil)
            return nickNameModel
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: - UITableViewDelegate
extension SJListViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailURL = contentsList[indexPath.row].detailUrl
        
        /* Comment
         ViewController를 init하는 시점에 필요한 파라미터들을 전달 할 수 있도록 initializer를 만드시는 습관을 가지시는게 좋습니다.
         외부로 배포하는 라이브러리로 제공하거나, 다른 사람들이 가져다 써야할 경우에, init 함수에 필요한 파라미터들을 받도록 만듬으로써,
         무엇이 필요한 요소인지 정확히 전달 할 수 있습니다.
         */
        let postViewController = SJPostViewController.init(nibName: "SJPostViewController", bundle: nil)
        postViewController.url = self.defaultURL + detailURL
        postViewController.contentsListModel = contentsList[indexPath.row]
        contentsList[indexPath.row].isRead = true
        navigationController?.pushViewController(postViewController, animated: true)
    }

}

// MARK: - UITableViewDataSource
extension SJListViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /* Comment
         목록에 표시되는 실제 셀의 내용이 다양할 수 있기때문에 (예를 들면 짧은 제목/ 긴제목 등)
         높이는 cell에 전달되는 내용으로 직접 높이를 가져올 수 있도록 구현하는게 좋습니다.
         */
        return 115
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /* Comment
         실제 dequeue를 못하는 경우에, 기본 셀을 리턴하는 게 아니라, 필요한 형태의 셀을 생성해서 전달해주는게 적절해보입니다.
         */
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"SJListTableViewCell") as? SJListTableViewCell else {
            return UITableViewCell()
        }
        cell.config(contentsList[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentsList.count
    }
    
    // reload 시 사용
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > contentsList.count - 5{
            paging = paging + 1
            self.setContentsList("\(paging)")
        }
    }
}
