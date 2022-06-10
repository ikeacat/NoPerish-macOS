//
//  CredentialsView+Delegate.swift
//  NoPerish
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import AppKit
import Foundation

// MARK: View Controller

class CredentialEntranceViewController: NSViewController, NSTextFieldDelegate {
    
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
        passwordField.delegate = self
        
        submit = NSButton(title: "Submit", target: nil, action: #selector(hitSubmit(_:)))
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.bezelColor = NSColor.systemBlue
        
        cancel = NSButton(title: "Cancel", target: nil, action: #selector(cancelEntrance(_:)))
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
    
    @objc func cancelEntrance(_ sender: Any?) {
        dismiss(self)
    }
    
    @objc func hitSubmit(_ sender: Any?) {
        // Disable all fields.
        submit.isEnabled = false
        cancel.isEnabled = false
        //nationField.isEnabled = false
        //passwordField.isEnabled = false
        
        // Disabling the text fields was causing the actively-edited one to be cleared on button press.
        
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
            verifyCredentials()
        } else {
            // was false, just pass values back.
            delegate?.credentialsFinished(self, nation: nationField.stringValue, password: passwordField.stringValue, alreadyVerified: false)
        }
    }
    
    func verifyCredentials() {
        let url = URL(string: "https://www.nationstates.net/cgi-bin/api.cgi")
        if(url == nil) {
            // TODO: Handle URL failure.
        }
        var request = URLRequest(url: url!)
        request.addValue(passwordField.stringValue, forHTTPHeaderField: "X-Password")
        request.addValue("NoPerish for macOS <mfryk268@gmail.com>", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        
        let encodedSpaces = nationField.stringValue.replacingOccurrences(of: " ", with: "+")
        request.httpBody = "nation=\(encodedSpaces)&q=ping".data(using: .utf8)
        
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                self.delegate?.credentialsFailed(self, description: "An error occured.", error: error)
                return;
            }
            
            let htresp = response as? HTTPURLResponse
            if(htresp != nil) {
                if(htresp!.statusCode == 200) {
                    // Check for X-Autologin header.
                    let autologin = htresp!.value(forHTTPHeaderField: "X-Autologin")
                    if(autologin == nil) {
                        // Status code was ok but no autologin header??? weird.
                        // This passes back the credentials as a "success" but alreadyVerified is false. Password param is the plaintext pwd.
                        DispatchQueue.main.async {
                            self.delegate?.credentialsFinished(self, nation: self.nationField.stringValue, password: self.passwordField.stringValue, alreadyVerified: false)
                        }
                        return
                    }
                    // Autologin was passed back, this means everything should be okay!!!
                    DispatchQueue.main.async {
                        self.delegate?.credentialsFinished(self, nation: self.nationField.stringValue, password: autologin!, alreadyVerified: true)
                    }
                } else {
                    self.delegate?.credentialsFailed(self, description: "HTTP response while verifying credentials was not 200. (was \(htresp!.statusCode))", error: nil)
                }
            } else {
                self.delegate?.credentialsFailed(self, description: "Failed to convert response parameter to HTTPURLResponse object.", error: nil)
            }
        }
        
        session.resume()
    }
    
}

// MARK: Delegate

protocol CredentialEntranceDelegate {
    
    // Sends the credentials back to the main view controller.
    // alreadyVerified MUST be false if shouldDoServerAuthenticationInViewController is false.
    // if alreadyVerified is true, the password parameter is the autologin header.
    func credentialsFinished(_ viewController: CredentialEntranceViewController, nation: String, password: String, alreadyVerified: Bool) // REQUIRED
    
    // Called every time credential verify failed. This will never be used if shouldDoServerAuthenticationInViewController is false, thus it's optional. Also has an error field if it failed because of an error check.
    func credentialsFailed(_ viewController: CredentialEntranceViewController, description: String, error: Error?) // Optional, default empty.
    
    func shouldDoServerAuthenticationInViewController(_ viewController: CredentialEntranceViewController) -> Bool // default: true
}

extension CredentialEntranceDelegate {
    func credentialsFailed(_ viewController: CredentialEntranceViewController, description: String, error: Error?) {}
    func shouldDoServerAuthenticationInViewController(_ viewController: CredentialEntranceViewController) -> Bool {return true}
}
