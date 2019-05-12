//
//  ETNetwork.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

enum ETNetworkResult {
    case success
    case failed
}

class ETNetwork: NSObject {
    
    /* Comment
     @escaping (_ success: ETNetworkResult, _ dateString: String?)->()
     success라는 이름보단 result가 적합할것 같습니다.
     dateString ???? 날짜...????
     */
    static func request(urlPath: String, completion:@escaping (_ success: ETNetworkResult, _ dateString: String?)->()) {
        let url = URL(string: urlPath)
        let urlSession = URLSession.shared
        
        let task = urlSession.dataTask(with: url! as URL) { (data, response, error) -> Void in
            if error == nil {
                let urlContent = String(data: data!, encoding: String.Encoding.utf8)
                if let urlContent = urlContent {
                    completion(.success, urlContent)
                }
            } else {
                completion(.failed, nil)
            }
        }
        task.resume()
    }
}
