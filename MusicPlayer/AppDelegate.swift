//
//  AppDelegate.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/6/15.
//  Copyright © 2015 Arc676. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func mediaKeyPressed(_ functionKey: String) {
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "MediaKeyPressed"),
            object: self,
            userInfo: ["fKey":functionKey]
        )
    }

}
