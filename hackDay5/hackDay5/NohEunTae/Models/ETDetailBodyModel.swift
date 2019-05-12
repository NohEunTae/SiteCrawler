//
//  ETDetailBodyModel.swift
//  hackDay5
//
//  Created by user on 2018. 11. 29..
//  Copyright © 2018년 hackDay. All rights reserved.
//

import UIKit

enum ETModelType {
    case string
    case image
}

struct ETDetailBodyModel {
    /* Comment
     ModelType이 옵셔널인게 조금 이상한 형태인것 같습니다.
     저 케이스가 아니라면, unknown or none 같은 형태로 추가해주고, 옵셔널을 빼야할거 같아요.
     */
    var modelType: ETModelType?
    var content: String
    
    init(modelType: ETModelType, content: String) {
        self.modelType = modelType
        self.content = content
    }
    
    init() {
        self.content = String()
    }
}
