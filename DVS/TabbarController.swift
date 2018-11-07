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
import SwiftyJSON


class TabbarController:UITabBarController, UITabBarControllerDelegate {
    
    var navBar: UINavigationBar!
    var json: JSON!
    var navItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        //self.setNavigationBar()
        //setting nav bar
        print("JSON in tabbar view did load : \(self.json)")
        if let rvc = self.viewControllers![0] as? ResultViewController {
            print("result VC assign json")
            rvc.json = nil
            rvc.json = self.json
        }
        if let swvc = self.viewControllers![1] as? SeenWithViewController {
            swvc.json = nil
            swvc.json = self.json
        }
        if let pvc = self.viewControllers![2] as? PairedViewController {
            pvc.json = nil
            pvc.json = self.json
        }
    }
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        //        var height = 0
        
        navBar = UINavigationBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: screenSize.width, height: 44))
        navItem = UINavigationItem(title: "Device Status")
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: nil, action: #selector(self.done))
        doneItem.image = UIImage(named: "ic_cancel.png")
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
        
    }
    @objc func done() { // remove @objc for Swift 3
        dismiss(animated: true)
    }
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        let tabBarIndex = tabBarController.selectedIndex
//        
//        
//        if tabBarIndex == 0 {
//            //do your stuff
//            navItem.title = "Device Status"
//        }
//        else if tabBarIndex == 1 {
//            //do your stuff
//            navItem.title = "Seen With"
//        }
//        else if tabBarIndex == 2 {
//            //do your stuff
//            navItem.title = "Paired IMSIs"
//        }
//    }
}
