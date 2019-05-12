//
//  ETElement.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

// 태그
class ETElement {
    var tag: String
    var content: String
    var attrs: [ETAttribute]
    
    weak var parentEle: ETElement?
    var childEles: [ETElement]
    
    init() {
        self.tag = String()
        self.content = String()
        self.childEles = [ETElement]()
        self.attrs = [ETAttribute]()
    }
    
    func addChild(_ element: ETElement) {
        self.childEles.append(element)
        element.parentEle = self
    }
    
    //Mark: - Set tags attribute
    
    func setAttributes(_ tagString: String) {
        let attrs = tagString.splitTag()
        if let first = attrs.first {
            self.tag = first
        }
        
        for i in 1..<attrs.count {
            let attr = setAttribute(attrs[i])
            if let validAttr = attr {
                self.attrs.append(validAttr)
            }
        }
    }
    
    func setAttribute(_ attrString: String) -> ETAttribute? {
        let attr = attrString.splitAttribute()
        guard attr.count > 1 else {
            return nil
        }
        return ETAttribute(name: attr[0], content: attr[1])
    }
    
    func equal(_ element: ETElement) -> Bool{
        guard self.attrs.count == element.attrs.count else {
            return false
        }
        
        for i in 0 ..< self.attrs.count {
            if !self.attrs[i].equal(element.attrs[i]) {
                return false
            }
        }
        
        return self.tag == element.tag && self.content == element.content
    }
    
    //Mark: - Find Tag
    func findFirstChild(tag: String) -> ETElement? {
        return self.childEles.filter { $0.tag == tag }.first
    }
    
    func findFirstChild(content: String) -> ETElement? {
        return self.childEles.filter { $0.attrs.first?.content == content }.first
    }
    
    func findChilds(content: String) -> [ETElement] {
        return self.childEles.filter { $0.attrs.first?.content == content }
        
    }
    
    func findFirstChild(contents: [String]) -> ETElement? {
        for content in contents {
            let child = self.childEles.filter { $0.attrs.first?.content == content }.first
            if let child = child {
                return child
            }
        }
        return nil
    }
    
    func findFirstChild(name: String) -> ETElement? {
        return self.childEles.filter { $0.attrs.first?.name == name }.first
    }
    
    func findFirstAttr(name: String) -> ETAttribute? {
        return self.attrs.filter { $0.name == name }.first
    }
    
    func findFirstAttr(names: [String]) -> ETAttribute? {
        for name in names {
            let attr = self.attrs.filter { $0.name == name }.first
            if let attr = attr {
                return attr
            }
        }
        return nil
    }
    
    func findFirstAttr(attrContent: String) -> ETAttribute? {
        return self.attrs.filter { $0.content == attrContent }.first
    }
    
    func findFirstAttr(attrContents: [String]) -> ETAttribute? {
        for content in attrContents {
            let attr = self.attrs.filter { $0.content == content }.first
            if let attr = attr {
                return attr
            }
        }
        return nil
    }
}
