//
//  ETHtmlParser.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

enum ETParsingType {
    case title
    case list
    case detailBody
    case detailHead
}

protocol ETHtmlParserDelegate {
    func finishedParsing<T>(result: T, parsingType: ETParsingType)
}

class ETHtmlParser: NSObject {
    
    var delegate: ETHtmlParserDelegate?
    
    // html string을 태그 별로 나누어 string array return
    func getLineArray(line: String) -> [String] {
        var lines: [String] = []
        line.enumerateLines { line, _ in
            let trimmedString = line.trimmingCharacters(in:
                NSCharacterSet.whitespacesAndNewlines
            )
            
            if !trimmedString.isEmpty {
                let splitString = trimmedString.splitHtmlByTag()
                for split in splitString {
                    if !split.isEmpty, !split.contains("!DOCTYPE"){
                        lines.append(split)
                    }
                }
            }
        }
        return lines
    }
    
    // type별로 시작태그를 찾고, 이전 내용들은 삭제하여 tree를 만듦
    // 닫는 태그가 있어야 tree가 정확하게 만들어지기 때문에, 필요에 따라 닫는 태그를 끝에 삽입
    func startParsing(line: String, parsingType: ETParsingType) {
        var contents = getLineArray(line: line)
        let htmlTreebuilder = ETHtmlTreeBuilder()

        switch parsingType {
        case .title:
            let startPoint = contents.firstIndex(of: "<title>")
            if let startPoint = startPoint {
                let range = 0...startPoint-1
                contents.removeSubrange(range)
            }
            break
        case .list:
            let startPoint = contents.firstIndex(of: "<div class=\"contents_jirum\">")
            if let startPoint = startPoint {
                let range = 0...startPoint-1
                contents.removeSubrange(range)
            }
            break
        case .detailBody:
            let startPoint = contents.lastIndex(of: "<body>")
            if let startPoint = startPoint {
                let range = 0...startPoint-1
                contents.removeSubrange(range)
            }
            break
        case .detailHead:
            let startPoint = contents.lastIndex(of: "<div class=\"content_view\" id=\"div_content\">")
            let insertPoint = contents.lastIndex(of: "<html>")
            
            if let insertPoint = insertPoint {
                contents.insert("</div>", at: insertPoint)
                contents.insert("</div>", at: insertPoint)
            }
            if let startPoint = startPoint {
                let range = 0...startPoint-1
                contents.removeSubrange(range)
            }
            break
        }
        
        htmlTreebuilder.buildTree(htmlLines: contents) { [weak self] in
            htmlTreebuilder.root = $0
            switch parsingType {
            case .title:
                if let root = htmlTreebuilder.root?.childEles.first {
                    self?.parsingHtmlTitle(container: root, parsingType: .title)
                }
                break
            case .list:
                if let root = htmlTreebuilder.root?.childEles.first {
                    self?.parsingHtmlList(container: root, parsingType: .list)
                }
                break
            case .detailBody:
                if let bodyRoot = htmlTreebuilder.root?.childEles.first {
                    let attchImageTree = ETHtmlTreeBuilder()
                    var attchImage = getLineArray(line: line)
                    let startPoint = attchImage.firstIndex(of: "<div class=\"post_article fr-view\">")
                    let insertPoint = attchImage.lastIndex(of: "<html>")
                    if let insertPoint = insertPoint {
                        attchImage.insert("</div>", at: insertPoint)
                    }
                    
                    if let startPoint = startPoint {
                        let range = 0...startPoint-1
                        attchImage.removeSubrange(range)
                    }
                    
                    attchImageTree.buildTree(htmlLines: attchImage, completion: {
                        attchImageTree.root = $0
                        if let headRoot = attchImageTree.root?.childEles.first {
                            self?.parsingHtmlDetailBody(headContainer: headRoot, bodycontainer: bodyRoot, parsingType: .detailBody)
                        }
                    })
                }
                break
            case .detailHead:
                if let root = htmlTreebuilder.root?.childEles.first {
                    self?.parsingHtmlDetailHead(container: root, parsingType: .detailHead)
                }
                break
            }
        }
    }
    
    func parsingHtmlTitle(container: ETElement, parsingType: ETParsingType) {
        self.delegate?.finishedParsing(result: container.content, parsingType: parsingType)
    }
    
    func parsingHtmlList(container: ETElement, parsingType: ETParsingType) {
        var startTime = CFAbsoluteTimeGetCurrent()
        var lists: [ListModel] = [ListModel]()
        for element in container.childEles {

            let validEle = element.findFirstAttr(attrContents: ["list_item symph_row jirum  ", "list_item symph_row jirum  sold_out"])
            guard validEle != nil  else {
                continue
            }
            
            var list: ListModel? = nil

            let titleContainer = element.findFirstChild(contents: ["list_title ", "list_title wide"])
            let listSubject = titleContainer?.findFirstChild(content: "list_subject")
            let titleText = listSubject?.findFirstAttr(name: "title")?.content
            
            let title = listSubject?.childEles.first
            let detailUrl = title?.findFirstAttr(name: "href")?.content
            
            let keyword = titleContainer?.findFirstChild(content: "keyword")
            let likes = keyword?.childEles.first?.childEles.first?.content
            
            let isSoldOut = keyword?.findFirstChild(content: "icon_info")?.content == "품절"
            let category = keyword?.findFirstChild(tag: "a")?.content
            
            let nickName = element.findFirstChild(contents: ["list_author", "list_author line"])?.childEles.first?.childEles.first?.childEles.first
            let gif = nickName?.findFirstAttr(name: "src")?.content
            let viewCnt = element.findFirstChild(content: "list_hit")?.childEles.first?.content
            let date = element.findFirstChild(content: "list_time")?.findFirstChild(content: "time popover")?.findFirstChild(content: "timestamp")?.content
            
            
            if let date = date,let category = category, let detailUrl = detailUrl, let likes = likes,
                let title = titleText, let viewCnt = viewCnt {
                
                var nick: NickNameModel?

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                guard let date = dateFormatter.date(from: date) else {
                    fatalError("[info] ERROR: Date conversion failed due to mismatched format.")
                }
                
                let intViewCnt = viewCnt.stringToInt()
                let intLikes = likes.stringToInt()
                
                if let gif = gif {
                    nick = NickNameModel(nickName: nil, gifNickName: gif)
                } else if let nickName = nickName?.content, nickName != "" {
                    nick = NickNameModel(nickName: nickName, gifNickName: nil)
                }
                
                
                if let nick = nick {
                    let next = "https://www.clien.net/\(detailUrl)"
                    let read = UserDefaults.standard.bool(forKey: next)
                    list = ListModel(detailUrl: next, category: category, title: title, nickNameModel: nick, date: date, likes: intLikes, viewCnt: intViewCnt, isRead: read, isSoldOut: isSoldOut)
                }
            }
            
            if let list = list {
                lists.append(list)
            }
        }
        
        if lists.count > 0 {
            self.delegate?.finishedParsing(result: lists, parsingType: parsingType)
        }
        
        let processTime = CFAbsoluteTimeGetCurrent() - startTime
        print("et 수행 시간 = \(processTime)")
    }
    
    func parsingHtmlDetailBody(headContainer: ETElement, bodycontainer: ETElement, parsingType: ETParsingType) {
        var list: [ETDetailBodyModel] = [ETDetailBodyModel]()
        var text = String()
        
        for element in headContainer.childEles {
            let url = element.childEles.first?.findFirstAttr(name: "src")?.content
            if let url = url {
                let detailModel = ETDetailBodyModel(modelType: .image, content: url)
                list.append(detailModel)
            }
        }
        
        for element in bodycontainer.childEles {
            if element.tag == "p", text != "" {
                text += "\n"
            }
            let images = element.findChilds(content: "attach-image")
            for image in images {
                let src = image.findFirstAttr(name: "src")?.content
                if let src = src {
                    if text != "" {
                        let detailModel = ETDetailBodyModel(modelType: .string, content: text)
                        list.append(detailModel)
                        text = ""
                    }
                    
                    let detailModel = ETDetailBodyModel(modelType: .image, content: src)
                    list.append(detailModel)
                }
            }

            let src = element.findFirstChild(tag: "img")?.findFirstAttr(name: "src")?.content
            if let src = src {
                if text != "" {
                    let detailModel = ETDetailBodyModel(modelType: .string, content: text)
                    list.append(detailModel)
                    text = ""
                }
                
                let detailModel = ETDetailBodyModel(modelType: .image, content: src)
                list.append(detailModel)
            }

            let gifUrl = element.findFirstChild(content: "img_gif")?.findFirstChild(content: "fr-dib fr-fil")?.findFirstAttr(name: "src")?.content
            if let gifUrl = gifUrl {
                if text != "" {
                    let detailModel = ETDetailBodyModel(modelType: .string, content: text)
                    list.append(detailModel)
                    text = ""
                }
                
                let detailModel = ETDetailBodyModel(modelType: .image, content: gifUrl)
                list.append(detailModel)
            }
            
            if let styleFontText = element.findFirstChild(name: "style")?.content {
                text += styleFontText
            }

            
            if element.content != "" {
                text += element.content
            }
            
            if let hyperlink = element.findFirstChild(content: "url")?.content {
                text += hyperlink
            }
            
            if let hyperlink = element.findFirstChild(content: "outlink")?.findFirstChild(tag: "a")?.content {
                text += hyperlink
            }
        }
        
        if text != "" {
            let detailModel = ETDetailBodyModel(modelType: .string, content: text)
            list.append(detailModel)
        }
        
        if bodycontainer.content != "" {
            let detailModel = ETDetailBodyModel(modelType: .string, content: bodycontainer.content)
            list.append(detailModel)
        }
        
        if list.count > 0 {
            self.delegate?.finishedParsing(result: list, parsingType: parsingType)
        }
    }
    
    func parsingHtmlDetailHead(container: ETElement, parsingType: ETParsingType) {
        var list: String?
        let postViewContainer = container.findFirstChild(content: "post_view")
        let attchLink = postViewContainer?.findFirstChild(content: "attached_link top")?.findFirstChild(content: "outlink")?.findFirstChild(tag: "a")?.content
        if let attchLink = attchLink {
            list = attchLink
        }
        
        self.delegate?.finishedParsing(result: list, parsingType: parsingType)
    }
}
