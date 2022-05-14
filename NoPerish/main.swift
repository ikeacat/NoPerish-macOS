//
//  main.swift
//  NoPerish
//
//  Created by Mason Frykman on 5/10/22.
//

import AppKit

let delegate = AppDelegate()
let menuBar = AppMenu()

NSApplication.shared.mainMenu = menuBar
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
