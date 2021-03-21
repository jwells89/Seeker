//
//  AppDelegate.swift
//  Seeker
//
//  Created by John Wells on 1/30/20.
//  Copyright © 2020 John Wells. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let wc = DirectoryWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        wc.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

