//
//  Application.swift
//  MusicPlayer
//
//  Created by Alessandro Vinciguerra on 10/9/15.
//  Copyright © 2015 Arc676. All rights reserved.
//

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
