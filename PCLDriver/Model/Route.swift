//
//  Route.swift
//  PCLDriver
//
//  Created by Varun Nair on 4/16/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation

struct Route: Decodable
{
    let RouteNo: Int?
    let RouteName: String?
    let DriverId: Int?
    let vehicleNo: String?
    var Customer: [Customer]?
}

struct Customer: Decodable
{
    var CustomerId: Int?
    var CustomerName: String?
    var StreetAddress: String?
    var City: String?
    var State: String?
    var Zip: Int?
    var PickupTime: String?
}
struct Driver: Decodable {
    var DriverId:Int?
    var DriverName:String?
    var PhoneNumber:String? 
}
