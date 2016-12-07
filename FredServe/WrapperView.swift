//
//  WrapperView.swift
//  FredServe
//
//  Created by Michael Cornell on 7/5/16.
//  Copyright © 2016 Spies & Assassins. All rights reserved.
//

import Cocoa

class WrapperView: NSView {
    
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true;
    }
    


}

class WrapperTextField: NSTextField {
    
    override func acceptsFirstMouse(theEvent: NSEvent?) -> Bool {
        return true;
    }
    
}
