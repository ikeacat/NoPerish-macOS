//
//  CredentialsView.swift
//  NoPerish
//
//  Created by Mason Frykman on 5/11/22.
//

import AppKit

// MARK: View Controller

class CredentialEntranceViewController: NSViewController {
    
    var delegate: CredentialEntranceDelegate?
    var upperTitle: String = "Setup"
    
    var nationField: NSTextField!
    var passwordField: NSTextField!
    var submit: NSButton!
    var cancel: NSButton!
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 220))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let upperTitle = NSTextField(labelWithString: upperTitle)
        upperTitle.font = .systemFont(ofSize: 50, weight: .bold)
        upperTitle.alignment = .center
        upperTitle.allowsDefaultTighteningForTruncation = true
        upperTitle.translatesAutoresizingMaskIntoConstraints = false
        
        nationField = NSTextField()
        nationField.placeholderString = "Nation"
        nationField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordField = NSSecureTextField()
        passwordField.placeholderString = "Password"
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.contentType = .password
        
        submit = NSButton(title: "Submit", target: nil, action: nil)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.bezelColor = NSColor.systemBlue
        
        cancel = NSButton(title: "Cancel", target: nil, action: nil)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(upperTitle)
        view.addSubview(nationField)
        view.addSubview(passwordField)
        view.addSubview(submit)
        view.addSubview(cancel)
        
        NSLayoutConstraint.activate([
            upperTitle.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            upperTitle.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            upperTitle.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            passwordField.topAnchor.constraint(equalTo: nationField.bottomAnchor, constant: 5),
            passwordField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            passwordField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            nationField.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            nationField.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            nationField.topAnchor.constraint(equalTo: upperTitle.bottomAnchor, constant: 10),
            
            submit.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            submit.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            submit.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -5),
            
            cancel.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            cancel.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            cancel.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
            
        ])
    }
    
    @objc private func hitSubmit(_ sender: Any?) {
        // Disable all fields.
        submit.isEnabled = false
        cancel.isEnabled = false
        nationField.isEnabled = false
        passwordField.isEnabled = false
        
        if(nationField.stringValue.isEmpty || passwordField.stringValue.isEmpty) {
            nationField.backgroundColor = .red
            passwordField.backgroundColor = .red
            submit.isEnabled = true
            cancel.isEnabled = true
            nationField.isEnabled = true
            passwordField.isEnabled = true
            return
        }
        
        let askDelForVerify = delegate?.shouldDoServerAuthenticationInViewController(self)
        if(askDelForVerify != false) { // Will trigger if true or delegate is nil (default is true)
            
        } else {
            // was false, just pass values back.
        }
    }
    
}

// MARK: Delegate

protocol CredentialEntranceDelegate {
    
    // Sends the credentials back to the main view controller.
    // alreadyVerified MUST be false if shouldDoServerAuthenticationInViewController is false.
    func credentialsFinished(_ viewController: CredentialEntranceViewController, nation: String, password: String, alreadyVerified: Bool) // REQUIRED
    
    // Called every time credential verify failed. This will never be used if shouldDoServerAuthenticationInViewController is false, thus it's optional.
    func credentialsFailed(_ viewController: CredentialEntranceViewController) // Optional, default empty.
    
    func shouldDoServerAuthenticationInViewController(_ viewController: CredentialEntranceViewController) -> Bool // default: true
}

extension CredentialEntranceDelegate {
    func credentialsFailed(_ viewController: CredentialEntranceViewController) {}
    func shouldDoServerAuthenticationInViewController(_ viewController: CredentialEntranceViewController) -> Bool {return true}
}
