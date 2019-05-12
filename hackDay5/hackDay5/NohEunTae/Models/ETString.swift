//
//  ETString.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import Foundation

extension String {
    
    // string형 정수, 실수를 정수로 변경
    func stringToInt() ->Int {
        var string = self.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        var int = Int()
        if string.last == "k" {
            string.removeLast()
            if let doubleValue = Double(string) {
                int = Int(doubleValue * 1000)
            }
            
        } else {
            if let intValue = Int(string) {
                int = intValue
            }
        }
        return int
    }
    
    
    // 앞뒤의 공백 줄바꿈이 제거된 전체 html을 태그 단위로 분해
    /* ex)
     <div class="menu_area"><a href="/service" class="link_home" title="클리앙홈">© CLIEN.NET</a><a href="#menuTop" class="link_top" title="메뉴맨위로"><i class="fa fa-bars"></i></a></div>
    
 ==> <div class="menu_area">
     <a href="/service" class="link_home" title="클리앙홈">
     © CLIEN.NET
     </a>
     <a href="#menuTop" class="link_top" title="메뉴맨위로">
     <i class="fa fa-bars">
     </i>
     </a>
     </div>
     */
    func splitHtmlByTag() -> [String] {
        var string = ""
        var desiredOutput = [String]()
        
        for ch in self {
            switch ch {
            case "<":
                if !string.isEmpty {
                    desiredOutput.append(string)
                    string = ""
                }
                string += String(ch)
                break
            case ">":
                string += String(ch)
                if !string.isEmpty {
                    desiredOutput.append(string)
                    string = ""
                }
                break
            default:
                string += String(ch)
                break
            }
        }
        if !string.isEmpty {
            desiredOutput.append(string)
        }
        return desiredOutput
    }
    
    // 태그 분해
    /* ex
     <a href="/service" class="link_home" title="클리앙홈">
 
==>  a href="/service"
     class="link_home"
     title="클리앙홈"
     */
    func splitTag() -> [String] {
        var string = ""
        var desiredOutput = [String]()
        var quotesCnt = 0
        var doubleQuotesCnt = 0
        
        for ch in self {
            switch ch {
            case "<":
                break
            case ">":
                break
            case " ":
                if !string.isEmpty, quotesCnt != 1, doubleQuotesCnt != 1 {
                    desiredOutput.append(string)
                    string = ""
                } else {
                    string += String(ch)
                }
                break
            case "\"":
                doubleQuotesCnt = doubleQuotesCnt > 0 ? 0 : doubleQuotesCnt + 1
                string += String(ch)
                break
            case "\'":
                quotesCnt = quotesCnt > 0 ? 0 : quotesCnt + 1
                string += String(ch)
                break
            default:
                string += String(ch)
                break
            }
        }
        if !string.isEmpty {
            desiredOutput.append(string)
        }
        return desiredOutput
    }
    
    // 속성 분해
    /* ex
     href="/service"

==>  href
     "/service"
     */
    func splitAttribute() -> [String] {
        var string = ""
        var desiredOutput = [String]()
        var quotesCnt = 0
        var doubleQuotesCnt = 0
        
        for ch in self {
            switch ch {
            case "=":
                if !string.isEmpty, quotesCnt != 1, doubleQuotesCnt != 1 {
                    desiredOutput.append(string)
                    string = ""
                } else {
                    string += String(ch)
                }
                break
            case "\"":
                doubleQuotesCnt = doubleQuotesCnt > 0 ? 0 : doubleQuotesCnt + 1
                string += String(ch)
                break
            case "\'":
                quotesCnt = quotesCnt > 0 ? 0 : quotesCnt + 1
                string += String(ch)
                break
            default:
                string += String(ch)
                break
            }
        }
        if !string.isEmpty {
            desiredOutput.append(string)
        }
        return desiredOutput
    }
    
    
    // Html에서 내용에 특수 기호를 표현하는 문자열을 원래 기호의 문자로 변경
    func replaceSpecialHTMLString() -> String {
        var content = self.replacingOccurrences(of: "&nbsp;", with: " ", options: .literal, range: nil)
        content = content.replacingOccurrences(of: "&lt;", with: "<", options: .literal, range: nil)
        content = content.replacingOccurrences(of: "&gt;", with: ">", options: .literal, range: nil)
        content = content.replacingOccurrences(of: "&amp;", with: "&", options: .literal, range: nil)
        content = content.replacingOccurrences(of: "&quot;", with: "\"", options: .literal, range: nil)
        return content
    }
    
    // string array의 모든 원소들 중 시작이 같은지를 판별
    func starts(stringArray tags: [String]) -> Bool {
        for tag in tags {
            if self.starts(with: tag) {
                return true
            }
        }
        return false
    }
    
    // 태그 여부를 판별(여는 태그, 닫는 태그)
    func isTag() -> Bool {
        return self.first == "<" && self.last == ">"
    }
    
    // 닫는 태그 여부를 판별
    func isClosingTag() -> Bool {
        return self.starts(with: "</")
    }
}

