//
//  RouteTableViewCell.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var customerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setCellData(object:Customer){
        customerName.text = object.CustomerName
        let address:String = String(format: "%@, %@, %@, %d", object.StreetAddress ?? "",object.City ?? "", object.State ?? "", object.Zip ?? 0)
          print(address)
        addressLabel.text = address
    }
    
}
