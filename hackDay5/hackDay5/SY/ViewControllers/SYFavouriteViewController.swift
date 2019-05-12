//
//  SYFavouriteViewController.swift
//  hackDay5
//
//  Created by sutie on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

/* Comment
 즐겨찾기 좋은 아이디어였습니다!
 */

class SYFavouriteViewController: UIViewController {
    
    var favouriteItems: [ListModel] = [] {
        didSet {
            if favouriteItems.count > 0 {
                self.notifyView.isHidden = true
            } else {
                self.notifyView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notifyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cellNib = UINib(nibName: "SYListTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "SYListTableViewCell")
        
        tableView.estimatedRowHeight = 60
    }
    
    static func create() -> SYFavouriteViewController {
        if let vc = Bundle.main.loadNibNamed("SYFavouriteViewController", owner: nil, options: nil)?.first as? SYFavouriteViewController {
            return vc
        }
        return UIViewController() as! SYFavouriteViewController
    }
    
    @IBAction func dismissSelf(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SYFavouriteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYListTableViewCell", for: indexPath) as! SYListTableViewCell
        cell.post = favouriteItems[indexPath.row]
        return cell
    }
}
