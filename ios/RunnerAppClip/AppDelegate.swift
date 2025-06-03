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
//    lazy var flutterEngine = FlutterEngine(name: "my_flutter_engine")

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        flutterEngine.run(withEntrypoint: "appClipMain", libraryURI: "main_app_clip.dart");
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

