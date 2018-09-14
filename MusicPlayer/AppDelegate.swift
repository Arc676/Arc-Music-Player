//
//  AppDelegate.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/6/15.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2015-8 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3) except linking proprietary
//Apple libraries is allowed

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

	@IBOutlet weak var autosaveMenuItem: NSMenuItem!
	var autosaveState = false

	/**
	Posts a notification that a function key was pressed (used to capture media keys)

	- parameters:
		- functionKey: Name of function key pressed
	*/
    @objc func mediaKeyPressed(_ functionKey: String) {
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "MediaKeyPressed"),
            object: self,
            userInfo: ["fKey":functionKey]
        )
    }

	@IBAction func setAutosave(_ sender: NSMenuItem) {
		autosaveState = !autosaveState
		sender.state = autosaveState ? .on : .off
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		if let state = UserDefaults.standard.object(forKey: "State") as? String {
			PlaylistController.loadState(state)
			ViewController.shouldUpdatePlaylist()
			autosaveState = true
			autosaveMenuItem.state = .on
		}
	}

	func applicationWillTerminate(_ notification: Notification) {
		if autosaveState {
			let state = PlaylistController.getWriteableState(saveState: true)
			UserDefaults.standard.set(state, forKey: "State")
		} else {
			UserDefaults.standard.removeObject(forKey: "State")
		}
	}

}
