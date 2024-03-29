//
//  Repo.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Foundation

struct Repo: Identifiable, Decodable {
    let id: Int
    let name: String
    let htmlUrl: String
    let fork: Bool
    let language: String?
    let watchersCount: Int?
    let description: String?
}

extension Repo: Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool { lhs.id == rhs.id }
}
