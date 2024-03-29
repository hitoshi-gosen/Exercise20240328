//
//  UserListView.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import SwiftUI

struct UserListView: View {
    @StateObject private var userListViewModel = UserListViewModel(githubAPI: GithubAPIImpl())
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userListViewModel.users) { user in
                    NavigationLink(destination: UserView(user: user)) {
                        UserRowView(user: user)
                            .onAppear {
                                if userListViewModel.users.last == user {
                                    userListViewModel.fetch()
                                }
                            }
                    }
                    .accessibilityIdentifier("userRow")
                }
                if userListViewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("userListViewTitle")
        }
        .navigationViewStyle(.stack)
        .task {
            userListViewModel.fetch()
        }
    }
}

#Preview {
    UserListView()
}
