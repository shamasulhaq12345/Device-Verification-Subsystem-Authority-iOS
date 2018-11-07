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
import Material
import Alamofire
import ReCaptcha
import SwiftyJSON
import BarcodeScanner
import AVFoundation
import DTTextField
import Moya

public extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}
class State {
    var value:Any = {}
    var test = ""
    func requestData(completion: ((_ value: String) -> Void)) {
        
        completion(test)
    }
}

class ViewController: UIViewController{
    
    var imei:String = ""
    let recaptcha = try? ReCaptcha()
    var jsonResult: JSON!
    
    var state: State?
    fileprivate let constant: CGFloat = 32
    var labelValues = [
        "123456789012345",
        "Samsung",
        "Galaxy",
        "S6",
        "Samsung China",
        "Smart Phone",
        "Android",
        "GSMA CDMA",
        "Compliance (Active)",
        "N/A",
        "N/A",
        "N/A"
    ]
    
    @IBOutlet weak var submitButton: RaisedButton!
    var scanButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imeiTextField: DTTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Declared at top of view controller
    var accessoryDoneButton: UIBarButtonItem!
    let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    override func viewDidLayoutSubviews() {
        scrollView.addSubview(contentView)//if the contentView is not already inside your scrollview in your xib/StoryBoard doc
        scrollView.contentSize = CGSize(
            width: self.contentView.frame.size.width,
            height: self.contentView.frame.size.height 
        ); //sets ScrollView content size
        
    }
    @IBAction func imeiTextFieldChanged(_ sender: DTTextField) {
        imei = sender.text!
        //to only allow 16 character a in imei
        if (imei.count > 16) {
            sender.deleteBackward()
        }
        
        //for live validation
        if (imei.count >= 14) && (imei.count <= 16) {
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                self.imeiTextField.hideError()
                
            }
            else{
                imeiTextField.errorMessage = getStringFromInfoPlist(key: "InvalidCharacterError")
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
            }
        }
        else {
            
            imeiTextField.errorMessage = getStringFromInfoPlist(key: "LengthError")
            imeiTextField.showError()
            self.imeiTextField.becomeFirstResponder()
        }
    }
    override func viewDidLoad() {
        
        
        //hiding activity indicator
        activityIndicator.isHidden = true
        
        // Configure ReCaptacha
        recaptcha?.configureWebView { [weak self] webview in
            webview.frame = self?.view.bounds ?? CGRect.zero
        }
        
        //disable submit button
        //        submitButton.isEnabled = false
        
        
        
        
        //add Done button above keypad
        self.accessoryDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(self.donePressed))
        self.accessoryDoneButton.image = UIImage(named: "ic_cancel.png")
        self.accessoryToolBar.items = [self.accessoryDoneButton]
        self.imeiTextField.inputAccessoryView = self.accessoryToolBar
        
        scanButton = UIButton(type: .custom)
        scanButton.setImage(UIImage(named: "ic_barcode_scanner.png"), for: .normal)
        scanButton.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0)
        scanButton.frame = CGRect(x: CGFloat(imeiTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        scanButton.addTarget(self, action: #selector(self.scanButtonClick(_:)), for: .touchUpInside)
        imeiTextField.rightView = scanButton
        imeiTextField.rightViewMode = .always
        imeiTextField.placeholderColor = UIColor.lightGray
        imeiTextField.borderColor = UIColor.lightGray
        
        
    }
    
    
    @objc func donePressed() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func buttonClick(_ sender: Any) {
        
        imei = imeiTextField.text!
        
        
        if (imei.count >= 14) && (imei.count <= 16) {
            if imei.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
                
                //hide error text from text field
                self.imeiTextField.hideError()
                
                //start loader and disable button
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                scanButton.isEnabled = false
                submitButton.isEnabled = false
                let provider = MoyaProvider<ApiRequest>()
                provider.request(.verifyImei(imei: self.imei, start: 1, limit:9)) { result in
                    self.activityIndicator.stopAnimating()
                    self.scanButton.isEnabled = true
                    self.submitButton.isEnabled = true
                    switch result {
                    case let .success(moyaResponse):
                        let data = moyaResponse.data // Data, your JSON response is probably in here!
                        let statusCode = moyaResponse.statusCode // Int - 200, 401, 500, etc
                        if statusCode == 200 {
                            self.jsonResult = JSON(data)
                            print("JSON in moya : \(self.jsonResult)")
                            self.performSegue(withIdentifier: "showResultSegue", sender: nil)
                        }
                        else
                        {
                            self.showErrorAlert()
                        }
                        
                    // do something in your app
                    case let .failure(error):
                        print(error)
                        self.showErrorAlert()
                        // TODO: handle the error == best. comment. ever.
                    }
                }
//                let parameters: Parameters = [
//                    "imei": self.imei,
//                    "subscribers":[
//                        "start":1,
//                        "limit":10
//                    ],
//                    "pairs":[
//                        "start":1,
//                        "limit":10
//                    ]
//                ]
//
//                Alamofire.request(getStringFromInfoPlist(key: "TykUrl")+"api/v1/fullstatus", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
//                    //stop loader and enable button
//                    self.activityIndicator.stopAnimating()
//                    self.scanButton.isEnabled = true
//                    self.submitButton.isEnabled = true
//                    print(response.result)
//
//                    switch response.result {
//                    case .success(let value):
//                        let statusCode = response.response?.statusCode
//                        if statusCode == 200 {
//                            self.jsonResult = JSON(value)
//                            print("JSON in alamofire : \(self.jsonResult)")
//
//
//
//                            self.performSegue(withIdentifier: "showResultSegue", sender: nil)
//                        }
//                        else
//                        {
//                            self.showErrorAlert()
//                        }
//                    case .failure(let error):
//                        print(error)
//                        self.showErrorAlert()
//
//                    }
//
//
//                }
                
                //                    }
                
            }
            else{
                imeiTextField.errorMessage = getStringFromInfoPlist(key: "InvalidCharacterError")
                imeiTextField.showError()
                self.imeiTextField.becomeFirstResponder()
            }
        }
        else {
            
            imeiTextField.errorMessage = getStringFromInfoPlist(key: "LengthError")
            imeiTextField.showError()
            self.imeiTextField.becomeFirstResponder()
        }
        
        
    }
    func onScanComplete(data: String)
    {
        imeiTextField.text = data;
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
    
    
    @IBAction func scanButtonClick(_ sender: Any) {
//        let scanViewController:ScannerViewController = ScannerViewController()
//        scanViewController.viewController = self
//        self.present(scanViewController, animated: true, completion: nil)
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "Barcode Scanner"
        present(viewController, animated: true, completion: nil)
    }
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        viewController.dismissalDelegate = self
        viewController.cameraViewController.barCodeFocusViewType = .oneDimension
        viewController.metadata.remove(at: viewController.metadata.index(of: AVMetadataObject.ObjectType.qr)!)
        return viewController
    }
    func showErrorAlert(){
        let alert = UIAlertController(title: "Oop!", message: "There was an error connecting to server. Please try again later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showResultSegue" {
            let tvc = segue.destination as! TabbarController
            tvc.json = self.jsonResult
        }
    }
    
}
// MARK: - BarcodeScannerCodeDelegate
extension ViewController: BarcodeScannerCodeDelegate {
    
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        self.imeiTextField.text = code
        self.dismiss(animated: true, completion: nil)
        // confirmImei(imei: code, controller: controller)
        
    }
    //    func confirmImei( imei:String, controller:BarcodeScannerViewController){
    //        //1. Create the alert controller.
    //        let alertViewController = NYAlertViewController()
    //
    //        // Set a title and message
    //        alertViewController.title = "Confirm IMEI"
    //        alertViewController.message = "Please confirm the scanned IMEI and tap OK to see device status"
    //        alertViewController.addTextField { (imeiTextField) in
    //            imeiTextField?.text = imei
    //
    //        }
    //        // Add alert actions
    //        let cancelAction = NYAlertAction(
    //            title: "Cancel",
    //            style: .cancel,
    //            handler: { (action: NYAlertAction!) -> Void in
    //                controller.reset()
    //                controller.dismiss(animated: true, completion: nil)
    //
    //        }
    //        )
    //        alertViewController.addAction(cancelAction)
    //
    //        let okAction = NYAlertAction(
    //            title: "Ok",
    //            style: .default,
    //            handler: { (action: NYAlertAction!) -> Void in
    //                let textField = alertViewController.textFields![0] // Force unwrapping because we know it exists.
    //                let imei = (textField as! UITextField).text
    //                if ((imei?.count)! >= 14) && ((imei?.count)! <= 16) {
    //                    if imei?.range(of: "^(?=.[a-fA-F]*)(?=.[0-9]*)[a-fA-F0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil {
    //                        //TODO add call to API
    //                        alertViewController.message = "Please confirm the scanned IMEI and tap OK to see device status"
    //                        alertViewController.messageColor = UIColor.black
    //                        self.dismiss(animated: true, completion: nil)
    //                        self.imeiAPICall(imei: imei!, ishideLoader: true)
    //
    //
    //                    }
    //                    else{
    //                        alertViewController.message = "IMEI must be a hexa-decimal number"
    //                        alertViewController.messageColor = UIColor.red
    //
    //
    //                    }
    //                }
    //                else {
    //                    //            prepareSnackbar()
    //                    //            animateSnackbar()
    //                    //            scheduleAnimation()
    //                    alertViewController.message = "IMEI must be 14 to 16 characters long"
    //                    alertViewController.messageColor = UIColor.red
    //
    //                }
    //
    //        }
    //        )
    //        alertViewController.addAction(okAction)
    //
    //        //add observer for text field changed
    //
    //        controller.present(alertViewController, animated: true, completion: nil)
    //
    //        //2. Add the text field. You can configure it however you need.
    ////        alert.addTextField { (textField:UITextField) in
    ////            textField.text = imei
    ////
    ////
    ////        }
    ////
    ////
    ////
    ////        // 3. Grab the value from the text field, and print it when the user clicks OK.
    ////        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
    ////
    ////        }))
    ////        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak alert] (_) in
    ////            controller.reset()
    ////        }))
    ////
    ////        // 4. Present the alert.
    ////        controller.present(alert, animated: true, completion: nil)
    //    }
    
    
}

// MARK: - BarcodeScannerErrorDelegate
extension ViewController: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
        controller.isOneTimeSearch = true
        controller.reset(animated: true)
    }
}

// MARK: - BarcodeScannerDismissalDelegate
extension ViewController: BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}








