//
//  ETImagePagingViewController.swift
//  hackDay5
//
//  Created by user on 2018. 12. 2..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit
/* Comment
 추가적으로 요청드린 사항인데 잘 개념을 잡고 구현하신것 같습니다!
 
 */
class ETImagePagingViewController: UIViewController {
    
    var pageController: UIPageViewController?
    var imageUrls: [String] = [String]()
    var startUrl: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageController?.dataSource = self
        
        
        guard let index = self.findStartIndex(), let maybefirstViewController = self.viewController(at: index) else {
            return
        }
        
        let startingViewController: ETImageViewerViewController = maybefirstViewController
        let viewControllers = [startingViewController]
        
        self.pageController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)

        guard let pageController = self.pageController else { return }

        self.addChildViewController(pageController)
        self.view.addSubview(pageController.view)
        
        let pageViewRect = self.view.bounds
        pageController.view.frame = pageViewRect
        pageController.didMove(toParentViewController: self)
    }

    init(imageUrls: [String], selectedUrl: String) {
        self.imageUrls = imageUrls
        self.startUrl = selectedUrl
        super.init(nibName: "ETImagePagingViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // startUrl을 통해 시작 index를 구한다
    func findStartIndex() ->Int? {
        return self.imageUrls.index(of: self.startUrl)
    }
    
    // 특정 index에 해당하는 viewcontroller를 구한다
    func viewController(at index: Int) -> ETImageViewerViewController? {
        if (self.imageUrls.isEmpty || self.imageUrls.count <= index) {
            return nil
        }
        let dataViewController = ETImageViewerViewController(imageUrl: self.imageUrls[index], index: index)
        return dataViewController
    }
}

// MARK: - PagingView Page View Controller DataSource

extension ETImagePagingViewController: UIPageViewControllerDataSource {
    
    // 이전 페이지에 대한 정보를 구한다.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? ETImageViewerViewController
        
        guard let index = vc?.pageIndex else {
            return nil
        }
        
        return index == 0 ? nil : self.viewController(at: index - 1)
    }

    // 다음 페이지에 대한 정보를 구한다
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as? ETImageViewerViewController

        guard let index = vc?.pageIndex else {
            return nil
        }
        return index == self.imageUrls.count ? nil : self.viewController(at: index + 1)
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.imageUrls.count
    }
}
