//
//  TasksService.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 13.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import RxSwift
import RxCocoa

class TasksService {
    static let shared = TasksService()
    
    private var tasksQueue = DispatchQueue(label: "com.alexsyn02.TasksService", attributes: .concurrent)
    private var _pendingTasks = [URLRequest: URLSessionTask]()
    
    var pendingTasks: [URLRequest: URLSessionTask] {
        var pendingTasks = [URLRequest: URLSessionTask]()
        tasksQueue.sync {
            pendingTasks = _pendingTasks
        }
        return pendingTasks
    }
    
    private var _pendingSearchRepositoryTasks = [URLRequest: URLSessionTask]()
    
    var pendingSearchRepositoryTasks: [URLRequest: URLSessionTask] {
        var pendingSearchTasks = [URLRequest: URLSessionTask]()
        tasksQueue.sync {
            pendingSearchTasks = _pendingSearchRepositoryTasks
        }
        return pendingSearchTasks
    }
    
    private init() {}
    
    func add(task: URLSessionTask, key: URLRequest) {
        tasksQueue.async(flags: .barrier) { [weak self] in
            self?._pendingTasks[key] = task
        }
    }
    
    func add(searchRepositoryTask task: URLSessionTask, key: URLRequest) {
        tasksQueue.async(flags: .barrier) { [weak self] in
            self?._pendingSearchRepositoryTasks[key] = task
        }
        add(task: task, key: key)
    }
    
    func remove(request: URLRequest) {
        tasksQueue.async(flags: .barrier) { [weak self] in
            self?._pendingTasks[request] = nil
        }
    }
    
    func remove(searchRepositoryRequest request: URLRequest) {
        tasksQueue.async(flags: .barrier) { [weak self] in
            self?._pendingSearchRepositoryTasks[request] = nil
        }
        remove(request: request)
    }
    
    func cancel(request: URLRequest) {
        let task = pendingTasks[request]
        task?.cancel()
        remove(request: request)
    }
    
    func cancel(searchRepositoryRequest request: URLRequest) {
        let task = pendingSearchRepositoryTasks[request]
        task?.cancel()
        remove(searchRepositoryRequest: request)
    }
    
    func cancelAllRequests() {
        pendingTasks.keys.forEach {
            cancel(request: $0)
        }
    }
    
    func cancelSearchRepositoryTasks() {
        pendingSearchRepositoryTasks.keys.forEach {
            cancel(searchRepositoryRequest: $0)
        }
    }
}
