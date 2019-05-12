//
//  SJImageViewExtensions.swift
//  hackDay5
//
//  Created by Suji Kim on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadImage(from url: URL) {
//        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
            DispatchQueue.main.async() {
                self.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
