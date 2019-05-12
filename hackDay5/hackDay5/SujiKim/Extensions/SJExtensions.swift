//
//  SJString.swift
//  hackDay5
//
//  Created by Suji Kim on 30/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import Foundation

extension String {
    func convertStringToDate() -> Date {
        var result:Date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self) {
            result = date
        }
        return result
    }
    func convertStringToInt() -> Int {
        let strings = self.split(separator: " ")
        var result:Double = 0
        if let number = Double(strings[0]) {
            result = number
        }
        if strings.count > 1 {
            switch strings[1] {
            case "k" :
                result = result*1000
            case "b" :
                result = result*1000000000
            case "m" :
                result = result*1000000
            default :
                break
            }
        }
        return Int(result)
    }
}

extension Date {
    func convertDateToString() -> String {
        var result:String = ""
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let current = dateFormatter.string(from: now)
        let date = dateFormatter.string(from: self)
        
        // 오늘이면
        if current == date {
            dateFormatter.dateFormat = "HH:mm"
            result = dateFormatter.string(from: self)
        }
        else { // 어제면
            dateFormatter.dateFormat = "MM-dd"
            result = dateFormatter.string(from: self)
        }
        
        return result
    }
    
    func convertDateToStringForPostPageDate() -> String {
        var result:String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        result = dateFormatter.string(from: self)
        
        return result
    }
}
