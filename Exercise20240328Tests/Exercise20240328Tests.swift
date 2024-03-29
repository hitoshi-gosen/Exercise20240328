//
//  Exercise20240328Tests.swift
//  Exercise20240328Tests
//
//  Created by 五泉仁 on 2024/03/28.
//

import XCTest
@testable import Exercise20240328

final class UserViewModelTests: XCTestCase {
    func testFechRepos() {
        XCTContext.runActivity(named: "isLoadingRepoがfalseでnextRepoUrlがnilでない場合") { _ in
            let githubAPIMock = GithubAPIMock()
            let target = UserViewModel(githubAPI: githubAPIMock)
            target.user = User(id: 0, login: "", reposUrl: "", avatarUrl: "")
            target.isLoadingRepo = false
            target.nextRepoUrl = "foo"
            
            let expectation = expectation(description: "APIリクエストの完了")
            let cancelable = target.$isLoadingRepo.dropFirst().filter { !$0 }.sink { _ in expectation.fulfill() }
            
            target.fetchRepos()
            
            wait(for: [expectation])
            
            XCTContext.runActivity(named: "APIリクエストが実行される") { _ in
                XCTAssertEqual(githubAPIMock.fetchReposCallCount, 1)
            }
        }
        
        XCTContext.runActivity(named: "isLoadingRepoがtrueの場合") { _ in
            let githubAPIMock = GithubAPIMock()
            let target = UserViewModel(githubAPI: githubAPIMock)
            target.user = User(id: 0, login: "", reposUrl: "", avatarUrl: "")
            target.isLoadingRepo = true
            target.nextRepoUrl = "foo"
            
            target.fetchRepos()
            
            XCTContext.runActivity(named: "APIリクエストが実行されない") { _ in
                XCTAssertEqual(githubAPIMock.fetchReposCallCount, 0)
            }
        }
        
        XCTContext.runActivity(named: "nextRepoUrlがnilの場合") { _ in
            let githubAPIMock = GithubAPIMock()
            let target = UserViewModel(githubAPI: githubAPIMock)
            target.user = User(id: 0, login: "", reposUrl: "", avatarUrl: "")
            target.isLoadingRepo = false
            target.nextRepoUrl = nil
            
            target.fetchRepos()
            
            XCTContext.runActivity(named: "APIリクエストが実行されない") { _ in
                XCTAssertEqual(githubAPIMock.fetchReposCallCount, 0)
            }
        }
    }
}

class GithubAPIMock: GithubAPI {
    var fetchUsersCallCount = 0
    var fetchUserDetailCallCount = 0
    var fetchReposCallCount = 0
    
    func fetchUsers(urlString: String) async throws -> (result: [User], nextUrl: String?) {
        fetchUsersCallCount += 1
        return ([], nil)
    }
    
    func fetchUserDetail(login: String) async throws -> UserDetail {
        fetchUserDetailCallCount += 1
        return UserDetail(id: 0, followers: 0, following: 0)
    }
    
    func fetchRepos(urlString: String) async throws -> (result: [Repo], nextUrl: String?) {
        fetchReposCallCount += 1
        return ([], nil)
    }
}
