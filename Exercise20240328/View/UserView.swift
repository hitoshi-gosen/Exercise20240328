//
//  UserDetailView.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import SwiftUI

struct UserView: View {
    @StateObject private var userViewModel: UserViewModel = UserViewModel(githubAPI: GithubAPIImpl())
    
    var user: User
    
    var body: some View {
        List {
            Section {
                UserRowView(user: user)
            }
            .listRowBackground(Color.clear)
            
            Section("fullname") {
                if let userDetail = userViewModel.userDetail {
                    Text(userDetail.name ?? String(localized: "na"))
                } else {
                    ProgressView()
                }
            }
            
            Section("followers") {
                if let userDetail = userViewModel.userDetail {
                    Text("\(userDetail.followers)")
                } else {
                    ProgressView()
                }
            }
            Section("following") {
                if let userDetail = userViewModel.userDetail {
                    Text("\(userDetail.following)")
                } else {
                    ProgressView()
                }
            }
            
            Section("repos") {
                ForEach(userViewModel.repos) { repo in
                    if let url = URL(string: repo.htmlUrl) {
                        NavigationLink(destination: WebView(url: url)) {
                            RepoRowView(repo: repo)
                                .onAppear {
                                    if userViewModel.repos.last == repo {
                                        userViewModel.fetchRepos()
                                    }
                                }
                        }
                        .accessibilityIdentifier("repoRow")
                    }
                }
            }
            
            if userViewModel.isLoadingRepo {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("userDetail")
        .task {
            userViewModel.user = user
            userViewModel.fetchRepos()
            userViewModel.fetchDetail()
        }
    }
}

struct RepoRowView: View {
    let repo: Repo
    
    var body: some View {
        VStack {
            HStack() {
                Text(String(localized: "name") + "：")
                Text(repo.name)
                Spacer()
            }
            HStack {
                Text(String(localized: "language") + "：")
                Text(repo.language ?? String(localized: "na"))
                Spacer()
            }
            HStack {
                Text(String(localized: "stars") + "：")
                if let watchersCount = repo.watchersCount {
                    Text("\(watchersCount)")
                } else {
                    Text("na")
                }
                Spacer()
            }
            HStack {
                Text(String(localized: "description") + "：")
                Text(repo.description ?? String(localized: "na"))
                Spacer()
            }
        }
    }
}
