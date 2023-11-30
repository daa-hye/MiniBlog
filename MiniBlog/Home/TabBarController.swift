//
//  TabBarController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/27/23.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {

        super.viewDidLoad()

        self.delegate = self

        tabBar.tintColor = .black

        let homeView = {
            let view = HomeViewController()
            view.tabBarItem.image = UIImage(systemName: "house.fill")
            return view
        }()

        let postView = {
            let view = PostViewController()
            view.tabBarItem.image = UIImage(systemName: "plus.circle.fill")
            return view
        }()

        setViewControllers([homeView, postView], animated: true)


    }

}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PostViewController {
            let view = PostViewController()
            view.modalPresentationStyle = .fullScreen
            present(view, animated: true)
            return false
        }
        return true
    }

}
