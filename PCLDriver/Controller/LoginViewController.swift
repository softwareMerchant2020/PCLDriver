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
        self.performSegue(withIdentifier: "showroutedetails", sender: self)
    }
   
    @IBAction func clearButtonClicked(_ sender: Any) {
        phoneNumberField.text = ""
        passwordField.text = ""
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "signupdriver", sender: self)
    }
}

