//
//  GithubAuthService.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa

class GithubService {
    static let shared = GithubService()
    
    private init() {}
    
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private var bag = DisposeBag()
    
    private func createAuthCredentials(username: String, password: String) -> String {
        return "Basic \("\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? "")"
    }
    
    func authorize(username: String, password: String) -> Single<User> {
        let url = URL(string: Configuration.githubURL + "/user")!
        let authCredentials = self.createAuthCredentials(username: username, password: password)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authCredentials, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return makeRequest(request)
    }
    
    func searchRepositories(query: String, page: Int = 0, perPage: Int = 15) -> Single<SearchRepositoriesResponse> {
        var urlComponents = URLComponents(string: Configuration.githubURL + "/search/repositories")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        
        guard let url = urlComponents.url else {
            return .error(CustomError.invalidURLError)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return makeRequest(request)
    }
    
    func makeRequest<T: Codable>(_ request: URLRequest) -> Single<T> {
        return Single<T>.create { single in
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return single(.error(CustomError.unknownError)) }
                
                if let data = data {
                    do {
                        let object = try self.decoder.decode(T.self, from: data)
                        single(.success(object))
                    } catch {
                        if let error = try? self.decoder.decode(GithubError.self, from: data), let response = response as? HTTPURLResponse {
                            single(.error(CustomError.responseError(statusCode: response.statusCode, description: error.message)))
                        } else {
                            single(.error(error))
                        }
                    }
                } else if let error = error {
                    single(.error(error))
                } else {
                    single(.error(CustomError.unknownError))
                }
            }.resume()
            
            return Disposables.create()
        }
    }
}
