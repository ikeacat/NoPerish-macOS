//
//  main.swift
//  NPStartup
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import Foundation

import AppKit

let delegate = AppDelegate()
//let menuBar = AppMenu()

//NSApplication.shared.mainMenu = menuBar
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
