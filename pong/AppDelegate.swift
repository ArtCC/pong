//
//  AppDelegate.swift
//  pong
//
//  Created by Arturo Carretero Calvo on 18/5/24.
//

import GameKit
import SpriteKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        authenticatePlayer()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    // MARK: - Game Center

    func authenticatePlayer() {
        let localPlayer = GKLocalPlayer.local

        localPlayer.authenticateHandler = { viewController, error in
            if let viewController, let rootVC = self.window?.rootViewController {
                rootVC.present(viewController, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                print("Player is authenticated")
            } else {
                if let error {
                    print("Error authenticating player: \(error.localizedDescription)")
                }
            }
        }
    }
}
