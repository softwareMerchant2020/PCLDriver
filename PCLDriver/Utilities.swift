//
//  Utilities.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/16/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    static func getAlertControllerwith(title:String, message:String) ->UIAlertController
    {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        return alert
    }
    static func getAlertControllerwith(title:String, message:String, alertActionTitle:String) -> UIAlertController {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        return alert
    }
    static func SerializedData(JSONObject:Any)->Data{
        let data = try? JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted, .sortedKeys])
        return data!
    }

}
