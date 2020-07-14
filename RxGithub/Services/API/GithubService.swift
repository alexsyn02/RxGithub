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
    
    private func createAuthCredentials(username: String = KeychainService.username, password: String = KeychainService.password) -> String {
        return "Basic \("\(username):\(password)".data(using: .utf8)?.base64EncodedString() ?? "")"
    }
    
    func authorize(username: String, password: String) -> Single<User> {
        let url = URL(string: Configuration.githubURL + "/user")!
        let authCredentials = self.createAuthCredentials(username: username, password: password)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authCredentials, forHTTPHeaderField: "Authorization")
        
        return makeRequest(request)
    }
    
    func searchRepositories(query: String, page: Int, perPage: Int = 15) -> Single<SearchRepositoriesResponse> {
        var urlComponents = URLComponents(string: Configuration.githubURL + "/search/repositories")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        
        guard let url = urlComponents.url else {
            return .error(CustomError.invalidURLError)
        }
        
        let authCredentials = self.createAuthCredentials()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authCredentials, forHTTPHeaderField: "Authorization")
        
        let handleTask: (URLSessionTask) -> () = { TasksService.shared.add(task: $0, key: request) }
        let handleResponseTask: (SearchRepositoriesResponse) -> () = { _ in TasksService.shared.remove(searchRepositoryRequest: request) }
        
        return makeRequest(request, handleTask: handleTask)
            .do(onSuccess: handleResponseTask)
    }
    
    func makeRequest<T: Codable>(_ request: URLRequest, handleTask: ((URLSessionTask) -> ())? = nil) -> Single<T> {
        return Single<T>.create { single in
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                TasksService.shared.remove(request: request)
                
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
            }
            
            handleTask?(task)
            TasksService.shared.add(task: task, key: request)
            
            task.resume()
            
            return Disposables.create()
        }
    }
}
