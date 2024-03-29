//
//  UserDetail.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Foundation

struct UserDetail: Decodable {
    var id: Int
    var name: String?
    var followers: Int
    var following: Int
}
