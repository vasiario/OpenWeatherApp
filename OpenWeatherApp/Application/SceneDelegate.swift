//
//  SceneDelegate.swift
//  OpenWeatherApp
//
//  Created by Vasilii Riaskin on 21.03.2024.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
           let window = UIWindow(windowScene: windowScene)
           let vc = WeatherViewController()
           window.rootViewController = UINavigationController(rootViewController: vc)
           self.window = window
           window.makeKeyAndVisible()
    }
}
