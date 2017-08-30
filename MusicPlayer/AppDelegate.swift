//
//  AppDelegate.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/6/15.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2015-7 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

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
