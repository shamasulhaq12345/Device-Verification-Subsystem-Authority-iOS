/**
 * Copyright (c) 2018 Qualcomm Technologies, Inc.
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Qualcomm Technologies, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 * NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit

import AeroGearHttp
import AeroGearOAuth2
import Material


extension String {
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

class LoginViewController: UIViewController {
    var userInfo: OpenIdClaim?
    var keycloakHttp = Http()
    var images: [UIImage] = []
    var currentIndex = 0
    @IBOutlet weak var loginButton: RaisedButton!
    @IBOutlet weak var nameLabel: UILabel!
//    var oauth2Module:KeycloakOAuth2Module
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create the authentication config
        
        
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        keycloakHttp = Http()
        let keycloakConfig = KeycloakConfig(
            clientId: getStringFromInfoPlist(key: "ClientId"),
            host: getStringFromInfoPlist(key: "KeycloakUrl"),
            realm: getStringFromInfoPlist(key: "Realm"),
            isOpenIDConnect: true)
        keycloakConfig.webView = KeycloakConfig.WebViewType.safariViewController
        
        
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        
        if oauth2Module.authorizationFields() != nil {
            self.performSegue(withIdentifier: "showMainPage", sender: nil)
        }
    }
    
    
  

    
    
    
    @IBAction func loginAsKeycloak(_ sender: AnyObject) {
        
        login(isLogin: false)
        
    }
   
    func login(isLogin:Bool){
        
        let keycloakConfig = KeycloakConfig(
            clientId: getStringFromInfoPlist(key: "ClientId"),
            host: getStringFromInfoPlist(key: "KeycloakUrl"),
            realm: getStringFromInfoPlist(key: "Realm"),
            isOpenIDConnect: true)
        keycloakConfig.webView = KeycloakConfig.WebViewType.safariViewController
        
        
        let oauth2Module = AccountManager.addKeycloakAccount(config: keycloakConfig)
        self.keycloakHttp.authzModule = oauth2Module
        
        
        
        
        oauth2Module.login {(accessToken: AnyObject?, claims: OpenIdClaim?, error: NSError?) in
            self.userInfo = claims
            print("error: \(String(describing: error?.description))")
            if error == nil {
                if let userInfo = claims {
                    
                    let userDefaults = UserDefaults.standard
                    if let name = userInfo.name {
                        userDefaults.set(name, forKey: "FullName")
                    }
                    if let username = userInfo.preferredUsername {
                        userDefaults.set(username, forKey: "Username")
                    }
                    if let email = userInfo.email {
                        userDefaults.set(email, forKey: "Email")
                    }
                    
                    self.performSegue(withIdentifier: "showMainPage", sender: nil)
                }
            }
            else{
                print("error: \(String(describing: error?.description))")
                self.showLoginErrorAlert()
                
            }
        }

    }
    func showLoginErrorAlert(){
        let alert = UIAlertController(title: "Oop!", message: "There was an error connecting to server. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
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
