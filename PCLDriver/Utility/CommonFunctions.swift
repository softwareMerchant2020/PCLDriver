//
//  CommonFunctions.swift
//  PCLDriver
//
//  Created by Rutul Desai on 4/14/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation
import UIKit

func Alert(message:String) -> UIAlertController {
    let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { [weak alert] (_) in
        alert!.dismiss(animated: true, completion: nil)
    }))
    return alert
}

func AlertText(message:String)->(UIAlertController,String){
    let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
    var email:String = ""
           //2. Add the text field. You can configure it however you need.
           alert.addTextField { (textField) in
               textField.text = ""
           }
           
           // 3. Grab the value from the text field, and print it when the user clicks OK.
           alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
               let textField = alert?.textFields![0]
            email = textField?.text ?? ""
           }))
           return (alert,email)
}


func navigation(ViewControllerName:String){
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let viewController = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerName)
    let nav = UINavigationController(rootViewController: viewController)
    UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController = nav;
}

func SerializedData(JSONObject:Any)->Data{
    let data = try? JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted, .sortedKeys])
    return data!
}

