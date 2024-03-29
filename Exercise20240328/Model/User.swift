//
//  User.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Foundation

struct User: Identifiable, Decodable {
    var id: Int
    var login: String
    var reposUrl: String
    var avatarUrl: String
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
}
