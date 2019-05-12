//
//  DetailModel.swift
//  hackDay5
//
//  Created by Suji Kim on 02/12/2018.
//  Copyright © 2018 hackDay. All rights reserved.
//

import Foundation

/* Comment
 타입의 경우, enum으로 정의해두면, 텍스트로 입력하는 부분에 대한 오타나 실수를 예방할 수 있고,
 .~~~ 같은 형식으로 접근할 수 있어서 조금 더 보기 쉬울것 같아요.
 */
struct SJDetailModel {
    let type:String
    let content:String // content는 이미지주소 또는 글
}
