//
//  AppDelegate.swift
//  HXPHPicker
//
//  Created by Slience on 2020/12/30.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController.init(rootViewController: BaseViewController.init())
        window?.makeKeyAndVisible()
        return true
    }
}

