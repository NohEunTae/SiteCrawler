//
//  ModelExtension.swift
//  hackDay5
//
//  Created by sutie on 29/11/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import UIKit
import Foundation

struct DetailModel {
    let content: String // 이미지 이거나 text이거나
    let type: CellType
}

enum CellType {
    case image, text
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension UILabel {
    func setStrikeThrough() {
        var attributes: [NSAttributedStringKey : Any] = [:]
        
        attributes[.strikethroughStyle] = NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue)
        self.attributedText = NSAttributedString(string: self.text ?? "",
                                                 attributes: attributes)
    }
}

extension DateFormatter {
    func convertToDate(dateString: String, isToday: Bool) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kr_ko")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString)!
    }
    
    func converToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "kr_ko")
        formatter.dateFormat = "yyyy-MM-dd"
        
        var formattedDate = ""
        
        let today = Date()
        let todayString = formatter.string(from: today)
        let dateString = formatter.string(from: date)
        
        // 오늘이라면
        if todayString == dateString {
            formatter.dateFormat = "HH:mm"
            formattedDate = formatter.string(from: date)
        } else { // 어제면
            formatter.dateFormat = "MM-dd"
            formattedDate = formatter.string(from: date)
        }
        
        return formattedDate
    }
}

