//
//  ViewController.swift
//  NoPerish
//
//  Created by Mason Frykman on 5/10/22.
//

import AppKit

class ViewController: NSViewController, CredentialEntranceDelegate {
    
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
    
    @objc private func toInstall(_ sender: Any) {
        let crView = CredentialEntranceViewController()
        crView.delegate = self
        crView.upperTitle = "Install"
        presentAsSheet(crView)
    }
    
    func credentialsFinished(_ viewController: CredentialEntranceViewController, nation: String, password: String, alreadyVerified: Bool) {
        return
    }

}

