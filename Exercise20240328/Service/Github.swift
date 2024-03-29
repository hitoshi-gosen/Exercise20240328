//
//  Github.swift
//  Exercise20240328
//
//  Created by 五泉仁 on 2024/03/28.
//

import Foundation
import Combine

protocol GithubAPI {
    func fetchUsers(urlString: String) async throws -> (result: [User], nextUrl: String?)
    func fetchUserDetail(login: String) async throws -> UserDetail
    func fetchRepos(urlString: String) async throws -> (result: [Repo], nextUrl: String?)
}

final class MockURLSession {
    static func instance() -> URLSession {
        assert(AppInfo.shared.isUITesting)
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
    
    final class MockURLProtocol: URLProtocol {
        override class func canInit(with request: URLRequest) -> Bool { true }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        override func startLoading() {
            if let url = request.url {
                let response = HTTPURLResponse(url: url,
                                statusCode: 200,
                                httpVersion: "HTTP/2",
                                headerFields: nil
                            )
                client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
                
                let file: String
                switch url.absoluteString {
                case "https://api.github.com/users":
                    file = "users"
                case let string where string.contains("repos"):
                    file = "repos"
                default:
                    file = "userDetail"
                }
                
                if let path = Bundle.main.path(forResource: file, ofType: "json"),
                   let json = try? String(contentsOfFile: path),
                   let jsonData = json.data(using: .utf8) {
                    client?.urlProtocol(self, didLoad: jsonData)
                } else {
                    assertionFailure("no dummy data")
                }
                
            }
            
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

/// Github APIへのアクセス
class GithubAPIImpl: GithubAPI {
    private let jsonDecoder: JSONDecoder
    private let session: URLSession
    
    init() {
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        session = AppInfo.shared.isUITesting ? MockURLSession.instance() : URLSession.shared
    }
    
    /// ユーザー一覧を取得する
    ///
    /// [該当API](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#list-users)
    /// - parameter urlString: 指定する場合は該当のURL。指定しない場合はデフォルトのURLを使用する。
    /// - returns: ユーザー一覧の配列とページング用の次のURL
    func fetchUsers(urlString: String) async throws -> (result: [User], nextUrl: String?) {
        return try await fetch(urlString: urlString)
//        let request = request(from: URL(string: urlString)!) // todo force check
//        let (data, response) = try await session.data(for: request)
//        let nextUrl = nextUrl(from: response)
//        return try (jsonDecoder.decode([User].self, from: data), nextUrl)
    }
    
    /// ユーザー詳細情報を取得する
    ///
    /// [該当API](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28#get-a-user)
    /// - parameter login: 取得するユーザーのハンドルID
    /// - returns: ユーザー詳細情報
    func fetchUserDetail(login: String) async throws -> UserDetail {
        let request = request(from: URL(string: "https://api.github.com/users/\(login)")!)
        let result = try await session.data(for: request)
        return try jsonDecoder.decode(UserDetail.self, from: result.0)
    }
    
    /// ユーザーのリポジトリ一覧を取得する
    ///
    /// [該当API](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user)
    /// - parameter urlString: 該当のURL
    /// - returns: ユーザーのリポジトリ一覧の配列とページング用の次のURL
    func fetchRepos(urlString: String) async throws -> (result: [Repo], nextUrl: String?) {
        return try await fetch(urlString: urlString)
//        let request = request(from: URL(string: urlString)!)
//        let (data, response) = try await session.data(for: request)
//        let nextUrl = nextUrl(from: response)
//        let repos = try (jsonDecoder.decode([Repo].self, from: data))
//        return (repos, nextUrl)
    }
    
    private func fetch<T: Decodable> (urlString: String) async throws -> (result: T, nextUrl: String?) {
        let request = request(from: URL(string: urlString)!)
        let (data, response) = try await session.data(for: request)
        let nextUrl = nextUrl(from: response)
        let result = try (jsonDecoder.decode(T.self, from: data))
        return (result, nextUrl)
    }
    
    private func nextUrl(from response: URLResponse) -> String? {
        guard let httpResponse = response as? HTTPURLResponse,
              let link = httpResponse.value(forHTTPHeaderField: "link"),
              let next = link.components(separatedBy: ",").first(where: { $0.hasSuffix("rel=\"next\"")}),
              let open = next.firstIndex(of: "<"),
              let close = next.firstIndex(of: ">")
        else {
            return nil
        }
        
        return String(next[next.index(open, offsetBy: 1)..<close])
    }
    
    private func request(from url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(GithubAccessToken.shared.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        return request
    }
}

final class GithubAccessToken {
    static let shared = GithubAccessToken()
    let accessToken: String

    private init() {
        guard let path = Bundle.main.path(forResource: "GithubAccessToken", ofType: "txt"),
              let token = try? String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines),
              !token.isEmpty
        else {
            fatalError("Need Github Access Token")
        }
        
        accessToken = token
    }
}
