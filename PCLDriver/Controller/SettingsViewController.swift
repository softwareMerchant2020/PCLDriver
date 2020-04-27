//
//  SettingsViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/26/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController: UIViewController {
    @IBOutlet weak var biometricsSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func toggledBiometricSwitch(_ sender: Any) {
        let bioSwitch = sender as! UISwitch
        if bioSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "allowBiometrics")
        }
        else {
            UserDefaults.standard.set(false, forKey: "allowBiometrics")
        }
        
    }
    @IBAction func changePasswordClicked(_ sender: Any) {
       let changePwdVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePwdViewController") as! ChangePwdViewController
        self.navigationController?.pushViewController(changePwdVC, animated: true)
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        Utilities.logOutUser()
        self.navigationController?.popToRootViewController(animated: true)
    }
}
