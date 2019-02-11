//
//  ScrollableSlider.swift
//
//  Created by Nate Thompson on 10/24/17.
//
// This file is also available from its original author under the terms of the MIT license. See
// the project README for more details.
//
//Copyright (C) 2019 Arc676/Alessandro Vinciguerra

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

class ScrollableSlider: NSSlider {
    override func scrollWheel(with event: NSEvent) {
        guard self.isEnabled else { return }
        
        let range = Float(self.maxValue - self.minValue)
        var delta = Float(0)
        
        //Allow horizontal scrolling on horizontal and circular sliders
		var vertical = false
		if #available(OSX 10.12, *) {
			vertical = self.isVertical
		}
        if vertical && self.sliderType == .linear {
            delta = Float(event.deltaY)
        } else if self.userInterfaceLayoutDirection == .rightToLeft {
            delta = Float(event.deltaY + event.deltaX)
        } else {
            delta = Float(event.deltaY - event.deltaX)
        }
        
        //Account for natural scrolling
        if event.isDirectionInvertedFromDevice {
            delta *= -1
        }
        
        let increment = range * delta / 100
        var value = self.floatValue + increment
        
        //Wrap around if slider is circular
        if self.sliderType == .circular {
            let minValue = Float(self.minValue)
            let maxValue = Float(self.maxValue)
            
            if value < minValue {
                value = maxValue - fabs(increment)
            }
            if value > maxValue {
                value = minValue + fabs(increment)
            }
        }
        
        self.floatValue = value
        self.sendAction(self.action, to: self.target)
    }
}
