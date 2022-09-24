//
//  SceneDelegate.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/11/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let dataController = DataController(modelName: "Inspirational_Bytes")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        dataController.load()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveViewContext()
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

