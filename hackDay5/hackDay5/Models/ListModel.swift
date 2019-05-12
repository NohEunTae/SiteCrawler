//
//  ListModel.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

struct ListModel {
    let detailUrl: String
    let category: String
    let title: String
    let nickNameModel: NickNameModel
    let date: Date
    
    let likes: Int?
    let viewCnt: Int
    var isRead: Bool = false
    let isSoldOut: Bool
}

