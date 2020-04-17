//
//  ViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    @IBAction func loginButtonClicked(_ sender: Any) {

        if (phoneNumberField.text!.isEmpty || passwordField.text!.isEmpty) {
            let alert = Utilities.getAlertControllerwith(title: "Required", message: "All fields are required", alertActionTitle: "Ok")
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let jsonBody = [
                "PhoneNumber": phoneNumberField.text,
                "Password": passwordField.text
            ]
            RestManager.APIData(url: "https://pclwebapi.azurewebsites.net/api/driver/DriverLogin", httpMethod: RestManager.HttpMethod.post.self.rawValue, body: Utilities.SerializedData(JSONObject: jsonBody)){Data,Error in
                if Error == nil {
                    do {
                        let resultData = try JSONDecoder().decode(RequestResult.self, from: Data as! Data)
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Login", message: resultData.Result, alertActionTitle: "Ok")
                                self.present(alert, animated: true)
                                self.performSegue(withIdentifier: "showroutedetails", sender: self)
                        }
                        
                    } catch let JSONErr{
                        DispatchQueue.main.async {
                            let alert = Utilities.getAlertControllerwith(title: "Login", message: JSONErr.localizedDescription, alertActionTitle: "Ok")
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            self.performSegue(withIdentifier: "showroutedetails", sender: self)
        }
        
    }
   
    @IBAction func clearButtonClicked(_ sender: Any) {
        phoneNumberField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "signupdriver", sender: self)
    }
}

