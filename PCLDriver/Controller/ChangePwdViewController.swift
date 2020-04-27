//
//  ChangePwdViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/26/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class ChangePwdViewController: UIViewController {
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return () }
        phoneNumber.text = String(format: "Phone Number: %@", username)

    }
    
    @IBAction func changePwdClicked(_ sender: Any) {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return () }
        if !(passwordField.text!.isEmpty || confirmPwdField.text!.isEmpty) {
            if Utilities.validatePassword(pwd: passwordField.text!, newPwd: confirmPwdField.text!) {
                let jsonBody = [
                    "PhoneNumber" : username,
                    "Password" : passwordField?.text as Any,
                    "ConfirmPassword" : confirmPwdField.text as Any
                    ] as [String : Any]
                RestManager.APIData(url: baseURL + changePwdAPI, httpMethod: RestManager.HttpMethod.post.self.rawValue, body: Utilities.SerializedData(JSONObject: jsonBody)){Data,Error in
                    if Error == nil {
                        do {
                            let resultData = try JSONDecoder().decode(RequestResult.self, from: Data as! Data)
                            if resultData.Result == "success" {
                                
                                DispatchQueue.main.async {
                                    let alert = Utilities.getAlertControllerwith(title: "Change Password", message: resultData.Result)
                                self.present(alert, animated: true, completion: {
                                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_ ) in
                                        Utilities.logOutUser()
                                        self.dismiss(animated: true, completion: nil)
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                })
                                }}
                            else {
                                DispatchQueue.main.async {
                                    let alert = Utilities.getAlertControllerwith(title: "Change Password", message: resultData.Result, alertActionTitle: "Ok")
                                    self.present(alert, animated: true)
                                }
                            }
                            
                        } catch let JSONErr{
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Change Password", message: JSONErr.localizedDescription, alertActionTitle: "Ok")
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
        }
        
    }
    

}
