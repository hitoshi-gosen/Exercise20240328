//
//  Exercise20240328App.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import SwiftUI

@main
struct ExerciseApp: App {
    init() {
        _ = AppInfo.shared
    }
    
    var body: some Scene {
        WindowGroup {
            UserListView()
        }
    }
}

class AppInfo {
    static let shared = AppInfo()
    let isUITesting: Bool
    private init() {
        isUITesting = ProcessInfo.processInfo.environment["UITest"] != nil
    }
}
