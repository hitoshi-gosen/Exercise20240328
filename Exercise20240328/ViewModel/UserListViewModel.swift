//
//  UserListView.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Combine

class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    
    private let githubAPI: GithubAPI
    private var nextUrl: String? = "https://api.github.com/users"

    init (users: [User] = [], githubAPI: GithubAPI) {
        self.users = users
        self.githubAPI = githubAPI
    }
    
    func fetch() {
        guard !isLoading, let next = nextUrl else { return }
        isLoading = true
        Task {
            do {
                let response = try await githubAPI.fetchUsers(urlString: next)
                nextUrl = response.nextUrl
                await MainActor.run {
                    users.append(contentsOf: response.result)
                    isLoading = false
                }
            } catch {
                print(error) // todo handle error
            }
        }
    }
}
