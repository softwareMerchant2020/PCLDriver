//
//  RouteTableViewCell.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var customerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setCellData(object:Customer){
        customerName.text = object.customerName
        let address:String = String(format: "%@, %@, %@, %d", object.streetAddress ,object.city , object.state , object.zip )
        addressLabel.text = address
        timeLabel.text = object.pickUpTime
    }
    
}
