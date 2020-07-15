//
//  Router.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 10.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import UIKit

class Router {
    static let shared = Router()
    
    private var window: UIWindow!
    private var rootNavigationVC: UINavigationController!
    
    var navigationStack: [UIViewController] { rootNavigationVC.viewControllers }
    
    private init() {}
    
    func makeVisible(windowScene: UIWindowScene) -> UIWindow {
        window = UIWindow(windowScene: windowScene)
        
        let rootVC = LoginVC.instantiate()
        rootVC.viewModel = LoginVM()
        rootNavigationVC = UINavigationController(rootViewController: rootVC)
        
        window.rootViewController = rootNavigationVC
        window.makeKeyAndVisible()
        
        return window
    }
    
    func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if let topController = topViewController() {
            DispatchQueue.main.async {
                topController.present(viewController, animated: animated, completion: completion)
            }
        }
    }
    
    func push(_ viewController: UIViewController, animated: Bool = true) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        viewController.navigationItem.backBarButtonItem = backItem
        
        DispatchQueue.main.async { [weak self] in
            self?.rootNavigationVC.pushViewController(viewController, animated: animated)
        }
    }
    
    func pop(animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.rootNavigationVC.popViewController(animated: animated)
        }
    }
    
    func popToViewController(type: AnyClass, completion: ((_ success: Bool) -> ())? = nil) {
        let maybeOurs = navigationStack.filter { $0.isKind(of: type)}.first
        
        if let vc = maybeOurs {
            rootNavigationVC.popToViewController(vc, animated: true)
            completion?(true)
            return
        }
        
        completion?(false)
    }
    
    func popToRoot(animated: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            self?.rootNavigationVC.popToRootViewController(animated: animated)
        }
    }
    
    func topViewController(base: UIViewController? = nil, ignoreModal: Bool = false) -> UIViewController? {
        let vc = base ?? rootNavigationVC// compiler error: Cannot use instance member 'rootBarVC' as a default parameter
        
        if let nav = vc as? UINavigationController, let visible = ignoreModal ? nav.topViewController : nav.visibleViewController {
            return topViewController(base: visible, ignoreModal: ignoreModal)
        }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected, ignoreModal: ignoreModal)
        }
        if !ignoreModal, let presented = vc?.presentedViewController {
            return topViewController(base: presented, ignoreModal: ignoreModal)
        }
        return vc
    }
    
    func topView() -> UIView? {
        var view = topViewController()?.view
        
        while view != nil && view?.superview != nil {
            view = view?.superview
        }
        return view
    }
    
    func showRepositoryList() {
        let vc = RepositoryListVC.instantiate()
        vc.viewModel = RepositoryListVM()
        self.push(vc)
    }
}
