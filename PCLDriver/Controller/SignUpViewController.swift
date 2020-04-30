//
//  SignUpViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/15/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit
import Foundation

class SignUpViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var confirmPwdField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func signUpClicked(_ sender: Any) {
//        goToLoginView(with: "", password: "")
        if (phoneNumberField.text == "" || passwordField.text == "" || confirmPwdField.text == "") {
           let alert = Utilities.getAlertControllerwith(title: "Required", message: "All fields are required")
            self.present(alert, animated: true, completion: nil)
        }
        else if !(Utilities.validatePassword(pwd: passwordField.text!, newPwd: confirmPwdField.text!)) {
            let alert = Utilities.getAlertControllerwith(title: "Mismatch", message: "The password does not match")
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let jsonBody = [
                "PhoneNumber": phoneNumberField.text,
                "Password": passwordField.text,
                "ConfirmPassword": confirmPwdField.text
            ]
            RestManager.APIData(url: baseURL + driverSignUpAPI, httpMethod: RestManager.HttpMethod.post.self.rawValue, body: Utilities.SerializedData(JSONObject: jsonBody)){Data,Error in
                if Data != nil {
                    do {
                        let resultData = try JSONDecoder().decode(RequestResult.self, from: Data as! Data)
                        if resultData.Result == "success" {
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Sign Up", message: "Sign Up success")
                                self.present(alert, animated: true, completion: {
                                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_ ) in
                                        self.dismiss(animated: true, completion: nil)
                                        self.goToLoginView(with:self.phoneNumberField.text! , password: self.passwordField.text!)
                                    }
                                })
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Sign Up", message: resultData.Result, alertActionTitle: "Ok")
                                self.present(alert, animated: true)
                            }
                        }
                    } catch let JSONErr{
                        DispatchQueue.main.async {
                            let alert = Utilities.getAlertControllerwith(title: "Sign Up", message: JSONErr.localizedDescription, alertActionTitle: "Ok")
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    func goToLoginView(with phoneNumber:String, password:String) {
        self.navigationController?.popViewController(animated: true)

        let loginVC = self.navigationController?.viewControllers[0] as! LoginViewController
        print(loginVC)
        loginVC.loginUsingUsernameAndPassword(username: phoneNumber, password: password)
        
    }
}
