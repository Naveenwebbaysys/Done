//
//  AppDelegate.swift
//  Done
//
//  Created by Mac on 26/05/23.
//

import UIKit
import IQKeyboardManagerSwift
import AWSS3

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        initializeS3()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    func initializeS3() {
           let poolId = "us-west-1:8651bac9-bc52-460c-a20b-0861b09680e1" // 3-1
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
//           let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USWest1, identityPoolId: poolId)//3-2
           let configuration = AWSServiceConfiguration(region: .USWest1, credentialsProvider: credentialsProvider)
           AWSServiceManager.default().defaultServiceConfiguration = configuration
           
           
       }
    
}

