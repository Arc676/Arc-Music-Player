//
//  Application.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/9/15.
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

class Application: NSApplication {
	
    override func sendEvent(_ theEvent: NSEvent) {
        if theEvent.type == .systemDefined && theEvent.subtype.rawValue == 8 {
            let keyCode = ((theEvent.data1 & 0xFFFF0000) >> 16)
            let keyFlags = (theEvent.data1 & 0x0000FFFF)
            // Get the key state. 0xA is KeyDown, OxB is KeyUp
            let keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA
            let keyRepeat = (keyFlags & 0x1)
            mediaKeyEvent(Int32(keyCode), state: keyState, keyRepeat: keyRepeat != 0)
        }
        super.sendEvent(theEvent)
    }
    
    func mediaKeyEvent(_ key: Int32, state: Bool, keyRepeat: Bool) {
        // Only send events on KeyDown. Without this check, these events will happen twice
        if (state) {
            switch(key) {
            case NX_KEYTYPE_PLAY:
                delegate!.perform(#selector(AppDelegate.mediaKeyPressed(_:)), with: "F8")
                break
            case NX_KEYTYPE_FAST:
                delegate!.perform(#selector(AppDelegate.mediaKeyPressed(_:)), with: "F9")
                break
            case NX_KEYTYPE_REWIND:
                delegate!.perform(#selector(AppDelegate.mediaKeyPressed(_:)), with: "F7")
                break
            default:
                break
            }
        }
    }
}
