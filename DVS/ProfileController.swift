/**
 * Copyright (c) 2018 Qualcomm Technologies, Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation


import UIKit
import AeroGearHttp
import AeroGearOAuth2
import Material

class ProfileController: UIViewController {
   
    
    var keycloakHttp = Http()

   
    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fullName.layer.borderWidth = 1.0
        fullName.layer.borderColor = UIColor.black.cgColor
        
        fullNameLabel.layer.borderWidth = 1.0
        fullNameLabel.layer.borderColor = UIColor.black.cgColor
        
        email.layer.borderWidth = 1.0
        email.layer.borderColor = UIColor.black.cgColor
        
        emailLabel.layer.borderWidth = 1.0
        emailLabel.layer.borderColor = UIColor.black.cgColor
        
        username.layer.borderWidth = 1.0
        username.layer.borderColor = UIColor.black.cgColor
        
        usernameLabel.layer.borderWidth = 1.0
        usernameLabel.layer.borderColor = UIColor.black.cgColor
        
        let userDefaults = UserDefaults.standard
        
        let fullNametxt = userDefaults.object(forKey: "FullName")
        let usernametxt = userDefaults.object(forKey: "Username")
        let emailtxt = userDefaults.object(forKey: "Email")
        
        
        
        
        if let name = fullNametxt as? String {
            fullName.text = name
        }
        
        if let user = usernametxt as? String {
            username.text = user
        }
        
        if let mail = emailtxt as? String {
            email.text = mail
        }
        
        
        
    }
   
    @IBAction func logoutListener(_ sender: RaisedButton) {
        let keycloakConfig = KeycloakConfig(
            clientId: getStringFromInfoPlist(key: "ClientId"),
            host: getStringFromInfoPlist(key: "KeycloakUrl"),
            realm: getStringFromInfoPlist(key: "Realm"),
            isOpenIDConnect: true)
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
//        self.keycloakHttp.authzModule = oauth2Module
//        oauth2Module.oauth2Session.clearTokens()
//        oauth2Module.revokeAccess(completionHandler: {obj,error in ()
//            print("error "+(error?.description)!)
//                self.dismiss(animated: true)
//        })
        oauth2Module.revokeAccess(completionHandler: {(response, error) in
            if (error != nil) {
                // do something with error
                print("error "+(error?.description)!)
            }
            // do domething
            oauth2Module.oauth2Session.clearTokens()
            self.dismiss(animated: true)
        })
        
        
        
        
    }
    private func getStringFromInfoPlist(key: String) -> String {
        var resourceFileDictionary: NSDictionary?
        
        //Load content of Info.plist into resourceFileDictionary dictionary
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            resourceFileDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if let resourceFileDictionaryContent = resourceFileDictionary {
            
            // Get something from our Info.plist like TykUrl
            
            return resourceFileDictionaryContent.object(forKey:key)! as! String
            
        }
        else{
            return ""
        }
    }
    
    
}
