//
//  SJHTMLPostParser.swift
//  hackDay5
//
//  Created by Suji Kim on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import Foundation

class SJHTMLPostParser {
    
    // 상세 화면에서의 content부분만 추출
    func contentParser(_ documents: String) -> String {
        let startPattern = "<div class=\"post_view\">"
        let endPattern = "<div class=\"post_comment\">"
        let str1 = documents.components(separatedBy: startPattern)
        let str2 = str1[1].components(separatedBy: endPattern)
//        print(str2[0])
        return str2[0]
    }
    
    // content에서 수정날짜 추출
    func getEditedDate(_ documents: String) -> String {
        let pattern = "(?<=<span class=\"lastdate\">수정일 : )([^\n]+)(?=</span>)"
        let editedDate = matches(for: pattern, in: documents)
        var result:String = ""
        if let date = editedDate.first {
            result = date
        }
        return result
    }
    
    // content에서 구매링크 추출
    func getAttachedLink(_ documents:String) -> String {
        var result:String = ""
        var attachedLink:[String] = [""]
        if documents.contains("<a class='url' href='") {
            let pattern = "(?<=<a class='url' href=')([^\']+)"
            attachedLink = matches(for: pattern, in: documents)
        }
        else if documents.contains("<a class='url' target='_blank' href='") {
            let pattern = "(?<=<a class='url' target='_blank' href=')([^\']+)"
            attachedLink = matches(for: pattern, in: documents)
        }
        
        if let link = attachedLink.first {
            result = link
        }
        return result
    }
    
    func getContents(_ documents:String) -> [SJDetailModel]{
        var result:[SJDetailModel] = []
        var detailModel:SJDetailModel?
        let startPattern = "<article>"
        let endPattern = "</article>"
        let str1 = documents.components(separatedBy: startPattern)
        let str2 = str1[1].components(separatedBy: endPattern)
        
        let contentPattern = "(?<=<p>)([^\\<]+)"
        let contentResult = matches(for: contentPattern, in: str2[0])
        for i in 0..<contentResult.count {
            detailModel = SJDetailModel.init(type: "string", content:contentResult[i])
            if let detail = detailModel {
                result.append(detail)
            }
        }
        
        let imagePattern = "(?<=<p><img class=\"fr-dib fr-fil\" src=\")([^\"]+)"
        let imageResult = matches(for: imagePattern, in: str2[0])
        for i in 0..<imageResult.count {
            detailModel = SJDetailModel.init(type: "image", content:imageResult[i])
            if let detail = detailModel {
                result.append(detail)
            }
        }
        
        let linkPattern = "(?<=<p><span class=\"outlink\"><a class=\"url\" href=\")([^\"]+)"
        let linkResult = matches(for: linkPattern, in: str2[0])
        for i in 0..<linkResult.count {
            detailModel = SJDetailModel.init(type: "string", content: linkResult[i])
            if let detail = detailModel {
                result.append(detail)
            }
        }
        
//        print(result)
        return result
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
