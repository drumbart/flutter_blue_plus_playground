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
    lazy var flutterEngine = FlutterEngine(name: "RunnerAppClipEngine")

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        flutterEngine.run(withEntrypoint: "appClipMain");
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
//        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

