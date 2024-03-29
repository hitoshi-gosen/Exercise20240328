//
//  UserRowView.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url:  URL(string: user.avatarUrl),
                       content: { $0.resizable() },
                       placeholder: { ProgressView() })
            .clipShape(Circle())
            .frame(width: 28, height: 28)
            
            Text(user.login)
        }
    }
}
