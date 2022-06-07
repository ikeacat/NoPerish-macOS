//
//  LandingViewController.swift
//  NoPerish
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import AppKit

class LandingViewController: NSViewController, CredentialEntranceDelegate {
    
    var crView: CredentialEntranceViewController?
    
    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ************
        // *  HEADER  *
        // ************

        let title = NSTextField(labelWithString: "NoPerish for macOS")
        title.font = .systemFont(ofSize: 40, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let versionCaption = NSTextField(labelWithString: "Version 1.0")
        versionCaption.font = .systemFont(ofSize: 18, weight: .light)
        versionCaption.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        view.addSubview(versionCaption)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            title.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            
            versionCaption.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            versionCaption.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        ])
        
        // ********************
        // *  Bottom buttons  *
        // ********************
        
        let changeCredentials = NSButton(title: "Change Credentials", target: nil, action: nil)
        changeCredentials.translatesAutoresizingMaskIntoConstraints = false
        changeCredentials.isEnabled = false
        
        let uninstall = NSButton(title: "Uninstall", target: nil, action: nil)
        uninstall.translatesAutoresizingMaskIntoConstraints = false
        uninstall.isEnabled = false
        
        let install = NSButton(title: "Install", target: nil, action: #selector(toInstall(_:)))
        install.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(changeCredentials)
        view.addSubview(uninstall)
        view.addSubview(install)
        
        NSLayoutConstraint.activate([
            changeCredentials.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            changeCredentials.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            
            uninstall.bottomAnchor.constraint(equalTo: changeCredentials.topAnchor, constant: -15),
            uninstall.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            
            install.bottomAnchor.constraint(equalTo: uninstall.topAnchor, constant: -15),
            install.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
        ])
        
        
    }
    
    @objc func toInstall(_ sender: Any) {
        crView = CredentialEntranceViewController()
        crView!.delegate = self
        crView!.upperTitle = "Install"
        presentAsSheet(crView!)
    }
    
    func credentialsFinished(_ viewController: CredentialEntranceViewController, nation: String, password: String, alreadyVerified: Bool) {
        // Credentials sheet is no longer useful.
        if(crView == nil) {
            // This shouldn't be called if that view is nil.
            return
        }
        crView!.dismiss(nil)
        
        if(!alreadyVerified) {
            // Failed to obtain autologin alert.
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Failed to obtain autologin (encrypted password). Please try again."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        // *****************
        // *  CREDENTIALS  *
        // *****************
        // Saves credentials to a specific location for NPStartup utility.
        // Nation spaces are converted to +.
        
        let fman = FileManager()
        
        let libCheck = fman.fileExists(atPath: "") // Check for existing Library folder.
        if(!libCheck) {
            let dirurl = URL(string: "Library/Application Support/NoPerish", relativeTo: fman.homeDirectoryForCurrentUser)
            if(dirurl == nil) {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Failed to create NoPerish Library URL object."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return
            }
            
            do {
                try fman.createDirectory(at: dirurl!, withIntermediateDirectories: false) // Create the directory.
            } catch {
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = "Failed to create NoPerish Library folder."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return
            }
        }
        
        let nationFmtd = nation.replacingOccurrences(of: " ", with: "+")
        
        let credsFilePath = fman.homeDirectoryForCurrentUser.path + "/Library/Application Support/NoPerish/credentials.conf"
        let writer = fman.createFile(atPath: credsFilePath, contents: "\(nationFmtd) \(password)".data(using: .utf8))
        if(!writer) {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Failed to write credentials to file."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
        
        // Writer being true assumes everything is fine.
        
        // *************
        // *  UTILITY  *
        // *************
        // Writes utility to the same library folder as before.
        // Enables utility for login using SMJobBless
        
        
        
        
        
    }

}
