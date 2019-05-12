//
//  ETAttribute.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

// 태그 속성
struct ETAttribute {
    var name: String
    /* Comment
     content, _content의 이름만 보면 두개가 왜 별도로 있는지 모르겠습니다.
     명확하게 용도에 맞게 구분되는 이름으로 짓는게 좋을 것 같아요.
     */
    var _content: String
    var content: String {
        get {
            return self._content
        }
        set(newValue) {
            // 속성 값 들어올 때, " or '가 있으면 제거
            if (newValue.first == "\"" && newValue.last == "\"") || (newValue.first == "\'" && newValue.last == "\'") {
                self._content = String(newValue.dropFirst())
                self._content = String(self._content.dropLast())
            } else {
                self._content = newValue
            }
        }
    }
    
    init(name: String, content: String) {
        self.name = name
        self._content = String()
        self.content = content
    }
    
    func equal(_ attribute: ETAttribute) -> Bool {
        return name == attribute.name && content == attribute.content
    }
}
