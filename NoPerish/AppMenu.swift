//
//  AppMenu.swift
//  NoPerish
//
//  Created by Mason Frykman on 5/11/22.
//

import AppKit

class AppMenu: NSMenu {
    
    private lazy var appName = ProcessInfo.processInfo.processName
    
    override init(title: String) {
        super.init(title: title)

        let mainMenu = NSMenuItem()
        mainMenu.submenu = NSMenu(title: "MainMenu")
        mainMenu.submenu?.items = [
            NSMenuItem(title: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""),
            NSMenuItem.separator(),
            NSMenuItem(title: "Preferences...", action: nil, keyEquivalent: ","),
            NSMenuItem.separator(),
            NSMenuItem(title: "Hide \(appName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""),
            NSMenuItem.separator(),NSMenuItem(title: "Quit \(appName)", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q")]
        
        items = [mainMenu]
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
