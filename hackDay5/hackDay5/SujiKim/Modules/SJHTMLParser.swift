//
//  HTMLParser.swift
//  hackDay5
//
//  Created by Suji Kim on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import Foundation

class SJHTMLParser {
    func contentListParser(_ documents: String) -> String {
        let startPattern = "<div class=\"contents_jirum\">"
        let endPattern = "<div class=\"list_bottom_ad\">"
        let str1 = documents.components(separatedBy: startPattern)
        let str2 = str1[1].components(separatedBy: endPattern)
        return str2[0]
    }
    
    func getDetailURL(_ documents:String) -> [String] {
        let pattern = "(?<=<a href=\")([^\"]+groupCd=)"
        let detailURLResult=matches(for: pattern, in: documents)
//        print(detailURLResult)
        return detailURLResult
    }
    
    func getTitle(_ documents:String) -> [String] {
        let pattern = "(?<=data-role=\"list-title-text\">)([^\"]+)(?=</a>)"
        let titleResult = matches(for: pattern, in: documents)
//        print(titleResult)
        return titleResult
    }
    
    func getCategory(_ documents:String) -> [String] {
        let pattern = "(?<=class=\"icon_keyword\">)([^\"]+)(?=</a>)"
        let categoryResult = matches(for: pattern, in: documents)
//        print(categoryResult)
        return categoryResult
    }
    
    func getLikes(_ documents:String) -> [String] {
        let pattern = "(?<=<i class=\"fa fa-heart\"></i>)([^\n]+)(?=</span>)"
        let likesResult = matches(for: pattern, in: documents)
//        print(likesResult)
        return likesResult
    }
    
    func getDate(_ documents:String) -> [String] {
        let pattern = "(?<=<span class=\"timestamp\">)([^\"]+)(?=</span></span>)"
        let dateResult = matches(for: pattern, in: documents)
//        print(dateResult)
        return dateResult
    }
    
    func getViewCount(_ documents:String) -> [String] {
        let pattern = "(?<=<span class=\"hit\">)([^\"]+)(?=</span>)"
        let viewCountResult = matches(for: pattern, in: documents)
//        print(viewCountResult)
        return viewCountResult
    }
    
    func getNickName(_ documents:String) -> [String] {
        let pattern = "(?<=<span class=\"nickname\">\n\t\t\t \n\t\t\t\t\t<span>)([^\"]+)(?=</span>\n\t\t</span>)|(?<=<img src=\")([^\"]+)(?=\" alt)"
        let nickNameResult = matches(for: pattern, in: documents)
//        print(nickNameResult)
        return nickNameResult
    }
    
    func getSoldOut(_ documents:String) {
        
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
