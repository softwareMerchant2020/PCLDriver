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
    var routeNumber:Int = 0
    let touchMe = BiometricIDAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      let touchBool = touchMe.canEvaluatePolicy()
      if touchBool {
       touchIDLoginAction()
      }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    func touchIDLoginAction()  {
        touchMe.authenticateUser() { [weak self] message in
          if let message = message {
            // if the completion is not nil show an alert
            let alertView = UIAlertController(title: "Error",
                                              message: message,
                                              preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Darn!", style: .default)
            alertView.addAction(okAction)
            self?.present(alertView, animated: true)
           self?.loginUsingUsernameAndPassword()
          } else {
           self?.transitToView()
          }
        }
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        loginUsingUsernameAndPassword()
    }
    func loginUsingUsernameAndPassword()
    {
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
                        let resultData = try JSONDecoder().decode(DriverRoute.self, from: Data as! Data)
                        if resultData.RouteNo>0 {
                            self.routeNumber = resultData.RouteNo
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Login", message: "Login success", preferredStyle: .alert)
                                let action = UIAlertAction(title: "Ok", style: .default) { (handler) in
                                    self.transitToView()
                                }
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                               
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Login", message: "Login Failed", alertActionTitle: "Ok")
                                self.present(alert, animated: true)
                            }
                        }
                        
                    } catch let JSONErr{
                        DispatchQueue.main.async {
                            let alert = Utilities.getAlertControllerwith(title: "Login", message: JSONErr.localizedDescription, alertActionTitle: "Ok")
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        
    }
    func transitToView()  {
        self.performSegue(withIdentifier: "showroutedetails", sender: self)
    }
    @IBAction func clearButtonClicked(_ sender: Any) {
        phoneNumberField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "signupdriver", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showroutedetails" {
            let routeListVC = segue.destination as! RouteListViewController
            routeListVC.routeNumber = self.routeNumber
            
        }
    }
}

