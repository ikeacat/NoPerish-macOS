//
//  PingViewController.swift
//  NPStartup
//
//  The project, NoPerish, which includes and is not limited to this source code file is licensed under the GNU General Public License v3.0
//  Get a copy at https://www.gnu.org/licenses/gpl-3.0.en.html or in the included LICENSE file.
//

import AppKit

class PingViewController: NSViewController {
    
    var pingingText: NSTextField!
    var pingingPV: NSProgressIndicator!
    
    var phaseTwoExitBtn: NSButton!
    var phaseTwoErrorOptDescription: NSTextField? // Appears on error.
    var phaseTwoErrorRetryBtn: NSButton? // Also appears on error.
    
    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 550, height: 65))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pingingText = NSTextField(labelWithString: "Pinging NationStates...")
        pingingText.translatesAutoresizingMaskIntoConstraints = false
        pingingText.font = .boldSystemFont(ofSize: 25)
        
        view.addSubview(pingingText)
        
        pingingPV = NSProgressIndicator()
        pingingPV.style = .spinning
        pingingPV.translatesAutoresizingMaskIntoConstraints = false
        pingingPV.isDisplayedWhenStopped = false
        
        view.addSubview(pingingPV)
        
        NSLayoutConstraint.activate([
            pingingText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pingingText.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            pingingText.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            pingingPV.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pingingPV.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ])
        
        pingingPV.startAnimation(nil)
        ping()
    }
    
    func ping() {
        // MARK: Credentials
        
        let fman = FileManager()
        
        let credChk = fman.fileExists(atPath: "\(fman.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish/credentials.conf")
        if(!credChk) {
            self.errorPing("Credentials file does not exist! Consider reinstalling?")
            return
        }

        let credFileData = fman.contents(atPath: "\(fman.homeDirectoryForCurrentUser.path)/Library/Application Support/NoPerish/credentials.conf")
        if(credFileData == nil) {
            self.errorPing("Failed to load credentials file contents.")
            return
        }

        let credentials = String(data: credFileData!, encoding: .utf8)!.split(separator: " ")
        if(credentials.count != 2) {
            self.errorPing("Too many values in split credentials file contents.")
            return
        }

        let username = String(credentials[0])
        let autologin = String(credentials[1])

        // MARK: Ping NationStates

        let url = URL(string: "https://www.nationstates.net/cgi-bin/api.cgi")
        if(url == nil) {
            self.errorPing("Failed to create URL object.")
            return
        }

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue(autologin, forHTTPHeaderField: "X-Autologin")
        request.setValue("NoPerish for macOS <mfryk268@gmail.com>", forHTTPHeaderField: "User-Agent")

        request.httpBody = "nation=\(username)&q=ping".data(using: .utf8)
        
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                DispatchQueue.main.async {
                    self.errorPing("Error passed in dataTask closure -- \(error)")
                }
                return
            }
            
            let htresponse = response as? HTTPURLResponse
            if(htresponse != nil) {
                if(htresponse!.statusCode == 200) {
                    NSLog("Success!")
                    DispatchQueue.main.async {
                        self.successfulPing()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorPing("HTTP Status code was not 200 (Was \(htresponse!.statusCode))")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorPing("Failed to convert response parameter to HTTPURLResponse")
                }
            }
        }

        session.resume()
    }
    
    func successfulPing() {
        pingingText.stringValue = "Success!"
        pingingText.textColor = .systemGreen
        
        pingingPV.removeFromSuperview()
        
        phaseTwoExitBtn = NSButton(title: "Exit", target: nil, action: #selector(exitApp(_:)))
        phaseTwoExitBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(phaseTwoExitBtn)
        
        NSLayoutConstraint.activate([
            phaseTwoExitBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phaseTwoExitBtn.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor)
        ])
        
    }
    
    func errorPing(_ description: String) {
        
        // Update existing UI.
        pingingText.stringValue = "Error :("
        pingingText.textColor = .systemRed
        
        pingingPV.stopAnimation(nil)
        
        // Add new UI elements.
        
        phaseTwoExitBtn = NSButton(title: "Exit", target: nil, action: #selector(exitApp(_:)))
        phaseTwoExitBtn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(phaseTwoExitBtn)
        
        phaseTwoErrorRetryBtn = NSButton(title: "Retry", target: nil, action: #selector(retry(_:)))
        phaseTwoErrorRetryBtn!.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(phaseTwoErrorRetryBtn!)
        
        phaseTwoErrorOptDescription = NSTextField(labelWithString: description)
        //phaseTwoErrorOptDescription!.textColor = .systemRed
        phaseTwoErrorOptDescription!.font = .messageFont(ofSize: 10)
        phaseTwoErrorOptDescription!.translatesAutoresizingMaskIntoConstraints = false
        phaseTwoErrorOptDescription!.maximumNumberOfLines = 3
        
        view.addSubview(phaseTwoErrorOptDescription!)
        
        
        NSLayoutConstraint.activate([
            phaseTwoExitBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phaseTwoExitBtn.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            
            phaseTwoErrorRetryBtn!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            phaseTwoErrorRetryBtn!.rightAnchor.constraint(equalTo: phaseTwoExitBtn.leftAnchor, constant: -10),
            
            phaseTwoErrorOptDescription!.topAnchor.constraint(equalTo: pingingText.bottomAnchor, constant: 2),
            phaseTwoErrorOptDescription!.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            phaseTwoErrorOptDescription!.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            phaseTwoErrorOptDescription!.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        
    }
    
    @objc func retry(_ sender: Any?) {
        // Reset UI
        phaseTwoErrorRetryBtn?.removeFromSuperview()
        phaseTwoErrorOptDescription?.removeFromSuperview()
        phaseTwoExitBtn.removeFromSuperview()
        
        
        pingingText.stringValue = "Pinging NationStates..."
        pingingText.textColor = .textColor
        
        pingingPV.startAnimation(nil)
        
        ping()
    }
    
    @objc func exitApp(_ sender: Any?) {
        NSApp.terminate(nil)
    }
    
}
