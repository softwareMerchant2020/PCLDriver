//
//  RouteListViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class RouteListViewController: UIViewController {
    var customerDetails:[RouteDetail] = [RouteDetail]()
    var routeNumber:Int?
    var selectedIndexpath:IndexPath?
    var customer:[Customer] = [Customer]()
    
    @IBOutlet weak var routeHeaderView: UIView!
    @IBOutlet var routeHeaderLabels: [UILabel]!
    
    @IBOutlet weak var routeListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        let userdefaults = UserDefaults.standard
        self.routeNumber = userdefaults.integer(forKey: "RouteNumber")
        
        logoutButton()
        loadApi()
    }
    func logoutButton() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(settingsButtonClicked(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    @objc func settingsButtonClicked(_ sender: Any) {
       let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
       self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    func loadApi() {
        RestManager.APIData(url: baseURL + getRouteDetail + "?RouteNumber=" + String(self.routeNumber ?? 0), httpMethod: RestManager.HttpMethod.post.self.rawValue, body: nil){
            (Data, Error) in
            if Error == nil{
                do {
                    self.customerDetails = try JSONDecoder().decode([RouteDetail].self, from: Data as! Data )
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .none
                    dateFormatter.dateFormat = "H:mm a"
                    dateFormatter.locale = Locale(identifier: "en_US")
                    
                    self.customer = self.customerDetails[0].customer.sorted(by: {
                        (dateFormatter.date(from: $0.pickUpTime)?.compare(dateFormatter.date(from: $1.pickUpTime) ?? Date())) == .orderedDescending })
                    print(self.customer)
                    self.loadTableView()
                } catch let JSONErr{
                    print(JSONErr.localizedDescription)
                }
            }
        }
    }
    func loadTableView() {
        DispatchQueue.main.async {
            self.routeListTableView.delegate = self
            self.routeListTableView.dataSource = self
            self.routeListTableView.register(UINib(nibName: "RouteTableViewCell", bundle: .main), forCellReuseIdentifier: "RouteTableViewCell")
            self.routeListTableView.tableHeaderView = self.routeHeaderView
            self.setHeaderLabels()
            self.routeListTableView.rowHeight = 102
        }
    }
    func setHeaderLabels() {
        for aLabel in routeHeaderLabels {
            aLabel.adjustsFontSizeToFitWidth = true
            if aLabel.tag == 0 {
                aLabel.text = String(format: "Route Name: %@",self.customerDetails[0].route.routeName )
            } else if aLabel.tag == 1 {
                aLabel.text = String(format: "Route Number: %d", self.customerDetails[0].route.routeNo)
            } else if aLabel.tag == 2 {
                aLabel.text = String(format: "Vehicle: %@",self.customerDetails[0].route.vehicleNo)
            } else if aLabel.tag == 3 {
                aLabel.text = String(format: "Number Of Customers in route: %d", self.customerDetails[0].customer.count)
            }
        }
    }
}
extension RouteListViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.customer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        
        cell.setCellData(object: (self.customer[indexPath.row]))
//        if customerDetails[0].customer[indexPath.row].collectionStatus == "Collected" {
//            cell.backgroundColor = #colorLiteral(red: 0.7560525686, green: 0.4933606931, blue: 0.5651173446, alpha: 1)
//            cell.isUserInteractionEnabled = false
//        }
//        else {
//            cell.backgroundColor = UIColor.white
//            cell.isUserInteractionEnabled = true
//        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexpath = indexPath
        self.performSegue(withIdentifier: "updatespecimendetails", sender: self)
    }
    func refreshTable() {
        self.loadApi()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updatespecimendetails" {
            let destinationVC = segue.destination as! DestinationDetailViewController
            let indexpath = routeListTableView.indexPathForSelectedRow
            let customerObj = customerDetails[0].customer[indexpath!.row]
            destinationVC.selectedCustomer = customerObj
            destinationVC.customerNumber = customerObj.customerID 
            destinationVC.routeNumber = self.routeNumber
            destinationVC.routeDetails = self.customerDetails
            routeListTableView.deselectRow(at: indexpath!, animated: true)
        }
    }
}
