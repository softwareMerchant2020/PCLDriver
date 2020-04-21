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
    
    var passwordItems: [KeychainPasswordItem] = []

    
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
        let credentials:(username:String, password:String) = checkLogin()
        if !credentials.username.isEmpty && !credentials.password.isEmpty {
            loginUsingUsernameAndPassword(username: credentials.username, password: credentials.password)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    func touchIDLoginAction()  {
        touchMe.authenticateUser() {  message in
          if let message = message {
            DispatchQueue.main.async {
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self.present(alertView, animated: true)
                self.loginButtonClicked(self as Any)
            }
          } else {
            self.transitToView()
          }
        }
    }
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        if (phoneNumberField.text!.isEmpty || passwordField.text!.isEmpty) {
            let alert = Utilities.getAlertControllerwith(title: "Required", message: "All fields are required", alertActionTitle: "Ok")
            self.present(alert, animated: true, completion: nil)
            
        } else {
            phoneNumberField.resignFirstResponder()
            passwordField.resignFirstResponder()
            
            loginUsingUsernameAndPassword(username: phoneNumberField.text!, password: passwordField.text!)
        }
    }
    func loginUsingUsernameAndPassword(username:String, password:String)
    {
            let jsonBody = [
                "PhoneNumber": username,
                "Password": password
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
                                    self.saveUsernamePasswordInKeychain(username: username, password: password)
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
    func transitToView()  {
        self.performSegue(withIdentifier: "showroutedetails", sender: self)
    }
    func saveUsernamePasswordInKeychain(username:String, password:String)  {
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if !hasLoginKey && !username.isEmpty {
          UserDefaults.standard.setValue(username, forKey: "username")
        }
          
        // 5
        do {
          // This is a new account, create a new keychain item with the account name.
          let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                  account: username,
                                                  accessGroup: KeychainConfiguration.accessGroup)
            
          // Save the password for the new item.
          try passwordItem.savePassword(password)
        } catch {
          fatalError("Error updating keychain - \(error)")
        }
          
        // 6
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
       
    }
    func checkLogin() -> (String,String) {
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return ("","") }
        
      do {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                account: username,
                                                accessGroup: KeychainConfiguration.accessGroup)
        let keychainPassword = try passwordItem.readPassword()
        return (username, keychainPassword)
      } catch {
        fatalError("Error reading password from keychain - \(error)")
      }
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

