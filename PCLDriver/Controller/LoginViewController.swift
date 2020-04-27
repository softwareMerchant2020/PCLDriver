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
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if touchBool && hasLoginKey {
            touchIDLoginAction()
        }
        else{
       loginWithCredentials()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        phoneNumberField.text = ""
        passwordField.text = ""
    }
    func loginWithCredentials() {
         let credentials:(username:String, password:String) = checkLogin()
                   if !credentials.username.isEmpty && !credentials.password.isEmpty {
                       phoneNumberField.text = credentials.username
                       passwordField.text = credentials.password
                       loginUsingUsernameAndPassword(username: credentials.username, password: credentials.password)
                   }
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
            self.loginWithCredentials()
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
            RestManager.APIData(url: baseURL + driverLoginAPI, httpMethod: RestManager.HttpMethod.post.self.rawValue, body: SerializedData(JSONObject: jsonBody)){Data,Error in
                if Error == nil {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: Data as! Data, options: .allowFragments) as! Dictionary<String,Any>
                        if jsonData["RouteNo"] != nil{
                            self.routeNumber = jsonData["RouteNo"] as! Int
                            let userdefaults = UserDefaults.standard
                            userdefaults.set(self.routeNumber, forKey: "RouteNumber")
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Login", message: "Login success")
                                self.present(alert, animated: true, completion: {
                                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (_ ) in
                                        self.saveUsernamePasswordInKeychain(username: username, password: password)
                                        self.transitToView()
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                let alert = Utilities.getAlertControllerwith(title: "Login", message: jsonData["Result"] as! String, alertActionTitle: "Ok")
                                self.present(alert, animated: true)
                            }
                        }
                        } catch let JSONErr {
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
            loaddriverDetails()
            let routeListVC = segue.destination as! RouteListViewController
            routeListVC.routeNumber = self.routeNumber
            
        }
    }
    func loaddriverDetails() {
        let defaults = UserDefaults.standard
        
        guard let username = defaults.value(forKey: "username") as? String else { return  }
        RestManager.APIData(url: "https://pclwebapi.azurewebsites.net/api/driver/GetDriver", httpMethod:RestManager.HttpMethod.get.self.rawValue , body:nil ) { Data,Error in
            if Error == nil {
                do {
                    let resultData = try JSONDecoder().decode([Driver].self, from: Data as! Data)
                    for aDriver in resultData {
                        if aDriver.PhoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines) ==  username {
                            defaults.setValue(aDriver.DriverId, forKey: "DriverId")
                            defaults.setValue(aDriver.DriverName, forKey: "DriverName")
                        }
                    }
                } catch {
                    print("Error decoding driver data")
                }
            }
        }
            
    }
}

