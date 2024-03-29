//
//  UserViewModel.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Combine

class UserViewModel: ObservableObject {
    @Published var repos: [Repo] = [] // todo encapsulate
    @Published var isLoadingRepo = false
    @Published var userDetail: UserDetail?
    @Published var isLoadingUserDetail = false
    
    private let githubAPI: GithubAPI
    var nextRepoUrl: String?
    var user: User! {
        didSet {
            nextRepoUrl = user.reposUrl
        }
    }
    
    init (githubAPI: GithubAPI) {
        self.githubAPI = githubAPI
    }
    
    func fetchRepos() {
        guard !isLoadingRepo, let next = nextRepoUrl else { return }
        isLoadingRepo = true
        Task {
            do {
                let response = try await githubAPI.fetchRepos(urlString: next)
                nextRepoUrl = response.nextUrl
                await MainActor.run {
                    repos.append(contentsOf: response.result.filter { !$0.fork } )
                    isLoadingRepo = false
                }
            } catch {
                print(error)  // todo handle error
            }
        }
    }
    
    func fetchDetail() {
        guard !isLoadingUserDetail else { return }
        isLoadingUserDetail = true
        Task {
            do {
                let detail = try await githubAPI.fetchUserDetail(login: user.login)
                await MainActor.run {
                    userDetail = detail
                    isLoadingUserDetail = false
                }
            } catch {
                print(error)  // todo handle error
            }
        }
    }
}
