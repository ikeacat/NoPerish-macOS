//
//  UninstallViewController.swift
//  NoPerish
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import AppKit
import ServiceManagement

class UninstallViewController: NSViewController {
    
    var update: NSTextField!
    
    var yesBtn: NSButton!
    var noBtn: NSButton!

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 120))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update = NSTextField(labelWithString: "Are you sure you'd like to uninstall?")
        update.font = .systemFont(ofSize: 20, weight: .light)
        update.translatesAutoresizingMaskIntoConstraints = false
        update.alignment = .center
        
        view.addSubview(update)
        
        yesBtn = NSButton(title: "Yes", target: nil, action: #selector(hasConfimed(_:)))
        yesBtn.bezelColor = .systemRed
        yesBtn.translatesAutoresizingMaskIntoConstraints = false
        
        noBtn = NSButton(title: "No", target: nil, action: #selector(popSelf(_:)))
        noBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(yesBtn)
        view.addSubview(noBtn)
        
        NSLayoutConstraint.activate([
            update.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            update.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            update.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            update.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            yesBtn.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -6),
            yesBtn.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            
            noBtn.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            noBtn.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 6)
        ])
    }
    
    @objc func hasConfimed(_ sender: Any?) {
        update.stringValue = "Disabling startup utility"
        
        noBtn.removeFromSuperview()
        yesBtn.removeFromSuperview()
        
        doUninstall()
    }
    
    func showErrorAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Fatal error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func doUninstall() {
        // *****************
        // *  STARTUP APP  *
        // *****************
        
        let disable = SMLoginItemSetEnabled("eu.masonfrykman.NPStartup" as CFString, false)
        if(!disable) {
            showErrorAlert("Failed to disable startup application.")
            popSelf(nil)
            return
        }
        
        // ********************
        // *  LIBRARY FOLDER  *
        // ********************
        
        update.stringValue = "Check for existance of NoPerish library folder."
        
        let fileMgr = FileManager()
        let libCheck = fileMgr.fileExists(atPath: "\(fileMgr.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish")
        if(libCheck) {
            update.stringValue = "Removing library folder."
            do {
                try fileMgr.removeItem(atPath: "\(fileMgr.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish")
            } catch {
                showErrorAlert("Failed to remove library folder.")
                popSelf(nil)
                return
            }
        } else {
            update.stringValue = "No library folder found."
        }
        
        finishedUninstall()
    }
    
    func finishedUninstall() {
        update.stringValue = "Finished uninstall successfully."
        update.textColor = .systemGreen
        
        // Add OK button
        
        let okBtn = NSButton(title: "Ok", target: nil, action: #selector(popSelf(_:)))
        okBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(okBtn)
        
        NSLayoutConstraint.activate([
            okBtn.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            okBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func popSelf(_ sender: Any?) {
        dismiss(self)
    }
    
}
