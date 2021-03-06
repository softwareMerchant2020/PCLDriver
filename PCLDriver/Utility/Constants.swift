//
//  Constants.swift
//  PCL Admin
//
//  Created by Rutul Desai on 4/16/20.
//  Copyright © 2020 Abihshek. All rights reserved.
//

import Foundation

let baseURL = "https://pclwebapi.azurewebsites.net/api/"
let totalSpecimens = "admin/GetTotalSpecimensCollected"
let addCustomer = "Customer/AddCustomer"
let getCustomer = "Customer/GetCustomer"
let addDriver = "driver/AddDriver"
let getDriver = "driver/GetDriver"
let driverLoginAPI = "driver/DriverLogin"
let driverSignUpAPI = "driver/DriverSignUp"
let addDriverLocation = "driver/AddDriverLocation"
let addRoute = "Route/AddRoute"
let getRoute = "Route/GetRoute"
let getLatestRouteNumber = "Route/GetLatestRouteNumber"
let getRouteDetail = "Route/GetRouteDetail"
let editRoute = "Route/EditRoute"
let getVehicle = "vehicle/GetVehicle"
let addVehicle = "vehicle/AddVehicle"
let addUpdateTransactionStatus = "admin/AddUpdateTransactionStatus"
let changePwdAPI = "driver/ChangePassword"

enum CollectionStatus: String, Decodable, CaseIterable {
    case notCollected = "Not Collected"
    case collected = "Collected"
    case rescheduled = "Rescheduled"
    case missed = "Missed"
    case closed = "Closed"
    case other = "Other"
    case arrived = "Arrived"
    

    static var statusList: [String] {
        return CollectionStatus.allCases.map { $0.rawValue }
      }
}
