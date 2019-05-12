//
//  MainViewController.swift
//  hackDay5
//
//  Created by GyeongwonYang on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        self.tabBar.isTranslucent = false
        var viewControllers: [UINavigationController] = [UINavigationController]()

        //이름 가나다순
        //수지님
        let viewControllerForSujiKim6: UIViewController = SJListViewController()
        viewControllerForSujiKim6.view.backgroundColor = .red
        viewControllers.append(self.navigationController(rootVC: viewControllerForSujiKim6, tabBarTitle:"SujiKim6", navigationTitle:"SujiKim6's V.C"))
        
        //은태님
        let viewControllerForNohEunTae: ETListViewController = ETListViewController()
        viewControllerForNohEunTae.view.backgroundColor = .white
        viewControllers.append(self.navigationController(rootVC: viewControllerForNohEunTae, tabBarTitle:"NohEunTae", navigationTitle:"NohEunTae's V.C"))
        
        //수연님
        let viewControllerForSynature14: UIViewController = SYMainViewController()
        viewControllerForSynature14.view.backgroundColor = .blue
        viewControllers.append(self.navigationController(rootVC: viewControllerForSynature14, tabBarTitle:"synature14", navigationTitle:"synature14's V.C"))
        
        self.setViewControllers(viewControllers, animated: true)
    }
    
    private func navigationController(rootVC: UIViewController!, tabBarTitle: String?, navigationTitle: String?) -> UINavigationController {
        let navigationController: UINavigationController = UINavigationController(rootViewController: rootVC)
        
        navigationController.navigationBar.isTranslucent = false
        navigationController.tabBarItem.title = tabBarTitle
        rootVC.title = navigationTitle
        
        return navigationController
    }
}

extension MainViewController: UITabBarControllerDelegate {
    //Show Your ViewController Using NavigationController
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let navigationController: UINavigationController =  UINavigationController.init(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

