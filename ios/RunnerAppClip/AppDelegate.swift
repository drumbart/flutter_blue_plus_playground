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
    lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        flutterEngine.run();
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

