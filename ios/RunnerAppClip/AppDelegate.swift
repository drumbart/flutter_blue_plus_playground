//
//  AppDelegate.swift
//  RunnerAppClip
//
//  Created by Bartek Tułodziecki on 02/06/2025.
//

import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Create custom Flutter engine with our entry point
        let flutterEngine = FlutterEngine(name: "RunnerAppClipEngine")
        flutterEngine.run(withEntrypoint: "appClipMain")
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // Create FlutterViewController with our custom engine
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        
        // Set up the window and root view controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = flutterViewController
        self.window.makeKeyAndVisible()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

