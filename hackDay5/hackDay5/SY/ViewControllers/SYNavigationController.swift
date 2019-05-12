//
//  SYNavigationController.swift
//  hackDay5
//
//  Created by sutie on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit

/* Comment
 이 네비게이션 컨트롤러는 쓰이지 않는 거 같은데 맞겠죠?
 
 */
class SYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let navBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 52))
        navBarView.backgroundColor = #colorLiteral(red: 0.7493922114, green: 0.8650314212, blue: 0.9286820292, alpha: 1)
        self.view.addSubview(navBarView)
        let mainVC = SYMainViewController()
        self.viewControllers = [mainVC]
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
