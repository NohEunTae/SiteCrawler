//
//  ETImageViewerViewController.swift
//  hackDay5
//
//  Created by user on 2018. 11. 30..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETImageViewerViewController: UIViewController {

    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex : Int = Int()
    var imageUrl: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: imageUrl) {
            self.downloadImage(from: url)
        }
        
        self.setScrollView()
        self.setBtns()
    }

    /* Comment
     아래 부분들은 willAppear보단 didLoad에서 적용해주는게 맞을 것 같습니다.
     일반적인 뷰컨트롤러 라이프사이클에 대해서 생각해보면요!
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    // 이미지 URL과 페이지 번호 설정
    init(imageUrl: String, index: Int) {
        self.pageIndex = index
        self.imageUrl = imageUrl
        super.init(nibName: "ETImageViewerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    // 닫기, 공유, 다운로드 버튼 타겟 설정
    func setBtns() {
        self.closeBtn.addTarget(self, action: #selector(closeBtnClicked), for: .touchDown)
        self.shareBtn.addTarget(self, action: #selector(shareBtnClicked), for: .touchDown)
        self.downloadBtn.addTarget(self, action: #selector(downloadBtnClicked), for: .touchDown)
    }
    
    // 스크롤뷰 설정
    func setScrollView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.delegate = self
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(self.scrollViewTapped))
        self.scrollView.addGestureRecognizer(scrollViewTap)
    }
    
    @objc func closeBtnClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 공유 버튼 클릭 이벤트
    @objc func shareBtnClicked() {
        if let image = self.imageView.image {
            let imageToShare = [image]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    // 다운로드 버튼 클릭 이벤트
    @objc func downloadBtnClicked() {
        if let image = self.imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // 다운로드 성공 실패 여부
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "확인", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "저장 완료", message: "이미지 저장이 완료되었습니다.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "확인", style: .default))
            present(ac, animated: true)
        }
    }
    
    // 스크롤뷰 탭하면 이전 hidden 상태와 반대로 취하여 클릭할 때 마다 꺼졌다 켜졌다 할 수 있도록 구현
    @objc func scrollViewTapped() {
        DispatchQueue.main.async {
            self.closeBtn.isHidden = !self.closeBtn.isHidden
            self.shareBtn.isHidden = !self.shareBtn.isHidden
            self.downloadBtn.isHidden = !self.downloadBtn.isHidden
        }
    }
}


// MARK: - Image Viewer Scroll View Delegate

extension ETImageViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    // scroll view가 minimumzoom scale일 때 드래그 할 경우 pop
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == self.scrollView.minimumZoomScale {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
