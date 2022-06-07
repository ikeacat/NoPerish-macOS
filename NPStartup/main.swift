//
//  main.swift
//  NPStartup
//
//  Created by Mason Frykman on 6/7/22.
//

import Foundation

import AppKit

let delegate = AppDelegate()
//let menuBar = AppMenu()

//NSApplication.shared.mainMenu = menuBar
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
