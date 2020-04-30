//
//  Route.swift
//  PCLDriver
//
//  Created by Varun Nair on 4/16/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation

struct RouteDetail: Codable {
    let route: Route
    let customer: [Customer]

    enum CodingKeys: String, CodingKey {
        case route = "Route"
        case customer = "Customer"
    }
}

// MARK: - Customer
struct Customer: Codable {
    let customerID: Int
    let zip, customerName, streetAddress, city, state: String
    let specimensCollected: Int
    let pickUpTime, collectionStatus: String
    let isSelected: Bool
    let custLat, custLog: Double

    enum CodingKeys: String, CodingKey {
        case customerID = "CustomerId"
        case customerName = "CustomerName"
        case streetAddress = "StreetAddress"
        case city = "City"
        case state = "State"
        case zip = "Zip"
        case specimensCollected = "SpecimensCollected"
        case pickUpTime = "PickUpTime"
        case collectionStatus = "CollectionStatus"
        case isSelected = "IsSelected"
        case custLat = "Cust_Lat"
        case custLog = "Cust_Log"
    }
}

// MARK: - Route
struct Route: Codable {
    let routeNo: Int
    let routeName: String
    let driverID: Int
    let vehicleNo: String

    enum CodingKeys: String, CodingKey {
        case routeNo = "RouteNo"
        case routeName = "RouteName"
        case driverID = "DriverId"
        case vehicleNo = "VehicleNo"
    }
}

typealias RouteDetails = [RouteDetail]

struct Driver: Decodable {
    var DriverId:Int?
    var DriverName:String?
    var PhoneNumber:String? 
}
