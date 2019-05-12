//
//  MainViewController.swift
//  hackDay5
//
//  Created by GyeongwonYang on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class SYMainViewController: UIViewController {
    let buyAndSellBoard = URL(string: "https://www.clien.net/service/board/jirum/")!
    let pageURL = "https://www.clien.net/service/board/jirum/?&od=T31&po="
    var startIndex = 0  // page 인덱스 번호
    var currentYOffset: CGFloat = 0.0 // 스크롤시 fav버튼 이동시키려고 현재 yOffset

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notifyView: UIView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    /* Comment
     아래 부분은 Set으로 구현한 부분은 칭찬해드리고싶어요!
     중복된 요소가 없는 경우라서 Array보다 Set이 적합합니다.
     */
    var visitedURL: Set<URL>!
    var postArray: [ListModel] = []
    var favouritePostArray: [ListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        /* Comment
         뷰의 생명주기를 생각해볼 때, viewWillAppear는 상세화면에 다녀와도 호출되고, 즐겨찾기 목록 화면에 다녀와도 호출될것 같은데요.
         이 경우, 매번 API 호출이 필요할지에 대해서 생각해볼 필요가 있습니다.
         
         엄청 빠르게 자주 바뀌는 데이터가 아니라면, 적절한 초기 시점에 한번, 페이징이 일어나는 시점에 호출 되도록 흐름을 만드는게 좋을것 같습니다.
         
         +) function 이름은 뭔가 API나 네트워크를 통해서 호출되는 것을 명확히 나타낼수 있게 지어주세요!
         */
        if postArray.count <= 0 {
            self.eachPage(index: self.startIndex)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
            UIView.animate(withDuration: 3.5, animations: {
                self.notifyView.alpha = 0
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        notifyView.layer.cornerRadius = 25
        favouriteButton.layer.cornerRadius = favouriteButton.frame.height * 0.5
        
        self.visitedURL = Set<URL>()
        
        let cellNib = UINib(nibName: "SYListTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "SYListTableViewCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    /* Comment
     위에 말했지만 이름을 조금 더 명확하게!
     func getPageList:(page: Int) 이런 식으로요.
     */
    func eachPage(index: Int) {
        for each in index...index+2 {
            if let url = verifyURL(urlString: pageURL + String(each)) {
                //               self.subURLs(url)
                self.setListModel(url: url)
                startIndex += 1
            }
        }
    }
    
    /*
     private func subURLs(_ url: URL) {
     do {
     let pattern = "(?<=<a href=\"/service/board/jirum/)([^\"]+)(?=\")"
     
     let reg = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
     var urlList: [URL] = [url]
     
     while urlList.popLast() != nil {
     print("before : \(Date.timeIntervalSinceReferenceDate)")
     let contents = try String(contentsOf: url)
     print("after : \(Date.timeIntervalSinceReferenceDate)")
     // 필요한 내용 추출
     let matchedStrings = reg.matches(in: contents, options: [], range: NSRange(location: 0, length: contents.utf16.count)) // NSString으로 변환하여 length값 읽는것과 동일한 방법
     .compactMap { Range($0.range, in: contents) }
     .map { String(contents[$0]) }
     
     for urlString in matchedStrings {
     // URL 검증
     let totalURLString = buyAndSellBoard.absoluteString + urlString
     if let url = verifyURL(urlString: totalURLString), !visitedURL.contains(url) {
     urlList.append(url)
     visitedURL.insert(url)
     }
     }
     }
     
     } catch {
     print(error.localizedDescription)
     }
     }
     */
    
    private func verifyURL(urlString: String) -> URL? {
        if let url = URL(string: urlString) {
            return url
        }
        return nil
    }
    
    /* Comment
     파싱하는 로직은 별도의 파일로 분리해서 가져가는게 좋을 것 같습니다.
     ViewController에서 해도 되는 role이긴 하지만,
     내용이 길어지고, 파싱만 하는 부분을 충분히 뽑아낼 수 있을 것 같아요.
     
     기능단위로 파일을 분리하는 것만으로도, 추후 코드에 대한 유지보수하기가 쉬워집니다.
     */
    private func setListModel(url: URL) {
        do {
            let contents = try String(contentsOf: url)
            var body = contents.components(separatedBy: "<div class=\"list_item symph_row jirum  \"")
            body.remove(at: 0)
            body.forEach { parseForList(contents: $0) }
            
        } catch {
            print(error)
        }
        
        /* Comment
         테이블뷰의 데이터를 갱신하는 부분에 대한 시점을 항상 고민하시는게 좋습니다.
         */
        self.tableView.reloadData()
    }
    
    /* Comment
     create()라는 함수를 통한 VC의 생성보다는,
     이니셜라이저를 만들어서 생성하는 방법으로 코딩하는것을 연습하시는게 좋습니다.
     */
    static func create() -> SYMainViewController {
        if let vc = Bundle.main.loadNibNamed("SYMainViewController", owner: nil, options: nil)?.first as? SYMainViewController {
            return vc
        }
        return UIViewController() as! SYMainViewController
    }
    
    @IBAction func favouriteButtonTapped(_ sender: Any) {
        let favVC = SYFavouriteViewController.create()
        favVC.favouriteItems = favouritePostArray
        self.present(favVC, animated: true, completion: nil)
    }
}

/* Comment
 아래 extension 부분이 하나의 파일로 빠져도 될거같아요.
 */
extension SYMainViewController {
    // 테이블뷰에 뿌릴 제목,조회수, 작성자, 업로드날짜 추출
    private func parseForList(contents: String) {
        do {
            let contentsLength = contents.utf16.count
            
            let categoryReg = try NSRegularExpression(pattern: "(?<=icon_keyword\">)([^<]+)", options: .caseInsensitive)
            let matchedCategory = categoryReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            let titlePattern = "(?<=data-role=\"cut-string\" title=\")([^\"]+)"
            let titleReg = try NSRegularExpression(pattern: titlePattern, options: .caseInsensitive)
            let matchedTitle = titleReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            
            // nickname 여러개가 추출됨. 그중에서 첫번째가 작성자 닉네임
            let writerReg = try NSRegularExpression(pattern: "(?<=<span class=\"nickname\">)([^\"]+)(?=\")", options: .caseInsensitive)
            let matchedWriter = writerReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            var writerInfo: String!
            var nickName: NickNameModel!
            
            // <img src=" 가 포함되면 image로 writer 표현해야함
            if matchedWriter.contains("<img src=") {
                let writerImageReg = try NSRegularExpression(pattern: "(?<=<img src=\")([^\"]+)(?=\" alt)",  options: .caseInsensitive)
                writerInfo = writerImageReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                    .compactMap { Range($0.range, in: contents) }
                    .map { String(contents[$0]) }.first
                nickName = NickNameModel.init(nickName: nil, gifNickName: writerInfo)
                
            } else {    // 닉네임이 text일 경우
                let writerTextReg = try NSRegularExpression(pattern: "(?<=<span>)([^<]+)", options: .caseInsensitive)
                writerInfo = writerTextReg.matches(in: matchedWriter, options: [], range: NSRange(location: 0, length: matchedWriter.utf16.count))
                    .compactMap { Range($0.range, in: matchedWriter) }
                    .map { String(matchedWriter[$0]) }.first
                nickName = NickNameModel.init(nickName: writerInfo, gifNickName: nil)
            }
            
            
            let linkReg = try NSRegularExpression(pattern: "(?<=<a href=\")([^\"]+)", options: .caseInsensitive)
            let matchedLink = linkReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            
            /// 업로드 날짜 파싱
            // 오늘일경우
            let whetherTodayOrNot = try NSRegularExpression(pattern: "(?<=\"time popover\">)([^<]+)", options: .caseInsensitive)
            let matchedWhetherToday = whetherTodayOrNot.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            let formatter = DateFormatter()
            var formattedDate: Date!
            // 오늘 업로드 된거라면 "23:14"
            let todayDateReg = try NSRegularExpression(pattern: "(?<=\"timestamp\">)([^<]+)", options: .caseInsensitive)
            let matchedDate = todayDateReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            formattedDate = formatter.convertToDate(dateString: matchedDate, isToday: matchedWhetherToday.contains(":"))
            
            
            let likesReg = try NSRegularExpression(pattern: "(?<=<i class=\"fa fa-heart\"></i> )([^<]+)", options: .caseInsensitive)
            let matchedLikes = likesReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first
            
            let viewCountReg = try NSRegularExpression(pattern: "(?<=\"hit\">)([^<]+)", options: .caseInsensitive)
            var matchedViewCount = viewCountReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first!
            
            if matchedViewCount.last == "m" ||
                matchedViewCount.last == "k" ||
                matchedViewCount.last == "b" {
                
                var tempString = matchedViewCount
                tempString.removeLast()
                guard var formattedDouble = Double(tempString) else {
                    return
                }
                
                if matchedViewCount.last == "m" {
                    formattedDouble *= 1000000
                } else if matchedViewCount.last == "k" {
                    formattedDouble *= 1000
                } else if matchedViewCount.last == "b" {
                    formattedDouble *= 1000000000
                }
                
                matchedViewCount = String(Int(formattedDouble))
            }
            
            let soldOutReg = try NSRegularExpression(pattern: "(?<=<span class=\"icon_info\">)[^<]+", options: .caseInsensitive)
            let soldOut =  soldOutReg.matches(in: contents, options: [], range: NSRange(location: 0, length: contentsLength))
                .compactMap { Range($0.range, in: contents) }
                .map { String(contents[$0]) }.first
            var isSoldOut = false
            if soldOut != nil {
                isSoldOut = true
            }
            
            let eachModel = ListModel.init(detailUrl: matchedLink, category: matchedCategory,
                                           title: matchedTitle, nickNameModel: nickName,
                                           date: formattedDate,
                                           likes: Int(matchedLikes ?? "0"), viewCnt: Int(matchedViewCount)!, isRead: false, isSoldOut: isSoldOut)
            
            self.postArray.append(eachModel)
        } catch {
            // error
            print(error)
        }
    }
    
}

extension SYMainViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if yOffset > 20 && yOffset > currentYOffset {
            UIView.animate(withDuration: 0.5, animations: {
                self.favouriteButton.transform = CGAffineTransform(translationX: 0, y: 150)
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.favouriteButton.transform = CGAffineTransform.identity
            })
        }
        
        currentYOffset = yOffset
    }
}


extension SYMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > postArray.count - 60 {
            self.eachPage(index: startIndex)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYListTableViewCell", for: indexPath) as! SYListTableViewCell
        cell.post = postArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PostVC로 이동해야함
        let postVC = SYPostViewController.create()
        /* Comment
         이니셜라이저로 아래 내용도 함께 전달받아서 생성하는게 좋을것 같습니다.
         */
        postArray[indexPath.row].isRead = true
        postVC.post = postArray[indexPath.row]
        self.navigationController?.pushViewController(postVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favouriteAction = UIContextualAction(style: .normal, title:  "Fav", handler: { (ac:UIContextualAction, view: UIView, success:(Bool) -> Void) in
            
            let post = self.postArray[indexPath.row]
            self.favouritePostArray.append(post)
            print("OK, add to favourite")
            
            success(true)
        })
        favouriteAction.image = UIImage(named: "star")
        favouriteAction.backgroundColor = #colorLiteral(red: 0.08730201199, green: 0.5290237567, blue: 0.5067982543, alpha: 0.9556399829)
        
        return UISwipeActionsConfiguration(actions: [favouriteAction])
    }
}


