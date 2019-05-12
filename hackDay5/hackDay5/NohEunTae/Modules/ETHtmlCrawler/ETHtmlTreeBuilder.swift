//
//  ETHtmlTreeBuilder.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

class ETHtmlTreeBuilder: NSObject {
    
    var root: ETElement?
    let ignoreTags = ["<strong", "</strong", "<s>", "</s>", "<hr>"] // 이 태그들은 Tree에서 제외(내용은 포함)
    let withOutClosingTags = ["<meta", "<link", "<img", "<input", "<col ", "<br"] // 닫는 태그가 없는 태그들
    
    override init() {
        super.init()
    }
    
    //Mark: Build Tree
    
    /*
        htmlLines는 다음과 같은 형태로 넘어온다.
     
        <html>
        <head>
        <title>
        타이틀 입니다.
        </title>
        </head>
        <body>
        </body>
        </html>
     
        Tree 생성 과정
     
        stack에 root노드 push (root노드는 임의의 노드)
        // stack = [root]
     
        <html>은 시작 태그 ==> 스택 top(root)의 자식으로 설정
        // tree = root -> html
        태그가 종료되지 않았으므로, stack에 push
        // stack = [root, html]
     
        <head>는 시작 태그 ==> 스택 top(html)의 자식으로 설정
        // tree = root -> html -> head
        태그가 종료되지 않았으므로, stack에 push
        // stack = [root, html, head]
     
        <title>은 시작 태그 ==> 스택 top(head)의 자식으로 설정
        // tree = root -> html -> head -> title
        태그가 종료되지 않았으므로, stack에 push
        // stack = [root, html, head, title]
     
        "타이틀 입니다." 태그가 아닌 내용 ==> 스택 top(title)의 내용으로 설정
        // tree = root -> html -> head -> title(타이틀 입니다.)
     
        </title>는 닫는 태그 ==> 스택 pop
        // stack = [root, html, head]
     
        </head>는 닫는 태그 ==> 스택 pop
        // stack = [root, html]
     
        <body>는 시작 태그 ==> 스택 top(html)의 자식으로 설정
        // tree = root -> html -> head -> title(타이틀 입니다.)
        //                     -> body
        태그가 종료되지 않았으므로, stack에 push
        // stack = [root, html, body]
     
        </body> ~ </html>는 닫는 태그 ==> 스택 pop
        // stack = [root, html] ==> [root] ==> count : 1 ==> 종료
     */
    
    func buildTree(htmlLines: [String], completion: (ETElement) -> ()) {
        var stack: [ETElement] = [ETElement]()
        let root: ETElement = ETElement()
        var isScript: Bool = false
        
        root.tag = "root"
        stack.append(root)

        for line in htmlLines {
            // script는 태그에서 제외하며, 내용또한 제외
            if line.starts(with: "<script") || line.starts(with: "<Script") {
                isScript = true
                continue
            } else if line.starts(with: "</script") {
                isScript = false
                continue
            }

            // script외의 경우
            if !isScript {
                
                // tag인 경우(닫는 태그, 여는 태그 포함)
                if line.isTag() {
                    
                    // 무시할 태그들로 시작하는 경우 continue
                    if line.starts(stringArray: ignoreTags) {
                        continue
                    }

                    // 닫는 태그일 경우
                    if line.isClosingTag() {
                        // stack pop
                        stack.removeLast()
                        
                        // count가 1이면 root만 남은 형태로, 실질적으로 empty 상태
                        if stack.count == 1 {
                            completion(root)
                            return
                        }
                    }
                        
                    // close 태그가 없는 태그일 경우 태그와 그에 해당하는 속성을 설정하고 stack top의 자식으로 설정
                    else if line.starts(stringArray: withOutClosingTags) {
                        let child: ETElement = ETElement()
                        child.setAttributes(line)
                        stack.last?.addChild(child)
                    }
                    // close 태그가 있는 태그일 경우 태그와 그에 해당하는 속성을 설정하고 stack top의 자식으로 설정
                    // 그리고 스택에 push한다. (종료된 태그가 이니기 때문에)
                    else {
                        let child: ETElement = ETElement()
                        child.setAttributes(line)
                        stack.last?.addChild(child)
                        stack.append(child)
                    }
                }
                // tag가 아니라 내용일 경우, stack top의 내용으로 설정.
                else {
                    stack.last?.content += line.replaceSpecialHTMLString()
                }
            }
        }
        // root 노드 전달
        completion(root)
    }
}
