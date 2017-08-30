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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func mediaKeyPressed(functionKey: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            "MediaKeyPressed",
            object: self,
            userInfo: ["fKey":functionKey]
        )
    }

}