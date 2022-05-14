//
//  AppDelegate.swift
//  NoPerish
//
//  Created by Mason Frykman on 5/10/22.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 640, height: 480), styleMask: [.miniaturizable, .titled, .unifiedTitleAndToolbar], backing: .buffered, defer: false)
        window?.contentViewController = ViewController()
        window?.title = "NoPerish"
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

