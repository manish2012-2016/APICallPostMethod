//
//  ViewController.swift
//  PostExample
//
//  Created by Manish Kumar on 28/03/17.
//  Copyright © 2017 appface. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var errorMessageShowinglLabel: UILabel!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var otpLabel: UILabel!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var deviceIdLebel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(UIDevice.current.identifierForVendor!.uuidString)
        otpLabel.isHidden = true
        otpTextField.isHidden = true
        errorMessageShowinglLabel.isHidden = true
        buttonLabel.isHidden =  true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        deviceIdLebel.text = UIDevice.current.identifierForVendor?.uuidString
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    @IBAction func okAction(_ sender: Any) {
        if (mobileNumberTextField.text?.isEmpty)!{
            
            errorMessageShowinglLabel.isHidden = false
            errorMessageShowinglLabel.text = "Mobile number is empty Pls provide mobile no."
            
        }else{
            var request = URLRequest(url: URL(string: "http://appfacewalletdevelopment-env.nm95dtimtp.ap-southeast-1.elasticbeanstalk.com/getRegistration")!)
            request.httpMethod = "POST"
            
            let mobileNo = mobileNumberTextField.text!
            let deviceId = deviceIdLebel.text!
            
            DispatchQueue.global().async {
                
                request.httpBody = "mobileNo=\(mobileNo)&deviceId=\(deviceId)".data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) {data,response,error in
                    guard let _ = data ,error == nil else{
                        print("error=\(error)")
                        
                        return
                    }
                    
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = String(data: data!, encoding: .utf8)
                    print("responseString = \(responseString)")
                    let dictionaryItem = self.convertToDictionary(text: responseString!)
                    print("converted File\(dictionaryItem!)")
                    print("extracting message = \(dictionaryItem!["data"]!)")
                    print("extracting message11111 = \(dictionaryItem!["message"]!)")
                    let data = dictionaryItem?["data"] as? [String : Any]
                    
                    DispatchQueue.main.async {
                        
                        if data != nil{
                            if data?["VerificationStatus"] as! String == "Verified" {
                                print("login Success")
                                self.otpLabel.isHidden = true
                                self.otpTextField.isHidden = true
                                //errorMessageShowinglLabel.isHidden = true
                                self.buttonLabel.isHidden =  true
                                self.performSegue(withIdentifier: "changePasswordSegue", sender: nil)
                                
                            }
                            else {
                                
                                self.errorMessageShowinglLabel.isHidden = false
                             self.errorMessageShowinglLabel.text = "Your mobile number is  registered "
                               self.otpLabel.isHidden = false
                                self.otpTextField.isHidden = false
                                self.buttonLabel.isHidden = false
                            print("fail")
                                
                                
                            }
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
    
    @IBAction func okOTPAction(_ sender: Any) {
        
        var request = URLRequest(url: URL(string: "http://appfacewalletdevelopment-env.nm95dtimtp.ap-southeast-1.elasticbeanstalk.com/otpVerification"
            
            )!)
        DispatchQueue.global().async {
            
        request.httpMethod = "POST"
        request.httpBody  = "mobileNo=\(self.mobileNumberTextField.text!)&deviceId=\(self.deviceIdLebel.text!)&otp=\(self.otpTextField.text!)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {data,response,error in
            guard let _ = data ,error == nil else{
                print("error=\(error)")
                
                return
            }
            
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                
                self.errorMessageShowinglLabel.isHidden = false
                self.errorMessageShowinglLabel.text = " Your otp is not matched"
            }
            
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            
            DispatchQueue.main.async {
                
            if let httpStatus1 = response as? HTTPURLResponse,httpStatus1.statusCode == 200{
                self.errorMessageShowinglLabel.isHidden = true
                self.otpLabel.isHidden = true
                self.otpTextField.isHidden = true
               // self.otpTextField.text?.trimmingCharacters(CharacterSet.w)
                //errorMessageShowinglLabel.isHidden = true
                self.buttonLabel.isHidden =  true
                self.performSegue(withIdentifier: "changePasswordSegue", sender: nil)
                
            }
            }
        }
        
        task.resume()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mobileNumberTextField.endEditing(true)
        otpTextField.endEditing(true)
    }
    
}




