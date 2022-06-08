//
//  LandingViewController.swift
//  NoPerish
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import AppKit
import ServiceManagement

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
        title.textColor = .init(named: "NPTextColor")
        
        let versionCapt = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Some version"
        
        let versionCaption = NSTextField(labelWithString: "Version \(versionCapt)")
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
        
        let uninstall = NSButton(title: "Uninstall", target: nil, action: #selector(toUninstall(_:)))
        uninstall.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    @objc func toUninstall(_ sender: Any?) {
        let uninstall = UninstallViewController()
        presentAsSheet(uninstall)
    }
    
    func credentialsFailed(_ viewController: CredentialEntranceViewController, description: String, error: Error?) {
        if(error != nil) {
            let alert = NSAlert(error: error!)
            alert.runModal()
        } else {
            let alert = NSAlert()
            alert.messageText = "Fatal error"
            alert.informativeText = description
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func credentialsFinished(_ viewController: CredentialEntranceViewController, nation: String, password: String, alreadyVerified: Bool) {
        
        // *********************
        // *  PASS BACK CHECK  *
        // *********************
        // Dismisses credential sheet
        // Ensures password is autologin.
        
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
        
        print(fman.homeDirectoryForCurrentUser.path)
        let libCheck = fman.fileExists(atPath: "\(fman.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish") // Check for existing Library folder.
        if(!libCheck) {
            let dirurl = URL(fileURLWithPath: "\(fman.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish")
            
            do {
                try fman.createDirectory(at: dirurl, withIntermediateDirectories: false) // Create the directory.
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
        // Enables Utility as login item.
        
        let submitJob = SMLoginItemSetEnabled("eu.masonfrykman.NPStartup" as CFString, true)
        if(submitJob) {
            let alert = NSAlert()
            alert.messageText = "Success!"
            alert.informativeText = "Successfully installed NoPerish!!! (F.Y.I: The Startup app may pop up with an error 'HTTP Status code was not 200 (Was 409)', this is normal.)"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        } else {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Failed to enable utility as login item."
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }
    }

}

