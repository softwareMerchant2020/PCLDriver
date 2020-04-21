//
//  RouteListViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class RouteListViewController: UIViewController {
    var routeNumber:Int = 11
    var customerDetails:[Customer] = [Customer]()
    
    
    @IBOutlet weak var routeListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        logoutButton()
        loadApi()
    }
    func logoutButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "power"), style: .plain, target: self, action: #selector(powerButtonClicked(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
    }
    @objc func powerButtonClicked(_ sender: Any) {
        Utilities.logOutUser()
        self.navigationController?.popToRootViewController(animated: true)
    }
    func loadApi() {
        RestManager.APIData(url: baseURL + getRouteDetail + "?RouteNumber=" + String(routeNumber), httpMethod: RestManager.HttpMethod.post.self.rawValue, body: nil){
            (Data, Error) in
            if Error == nil{
                do {
                    self.customerDetails = try JSONDecoder().decode([Customer].self, from: Data as! Data )
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
            self.routeListTableView.rowHeight = 102
        }
    }
}
extension RouteListViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.customerDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        cell.setCellData(object: customerDetails[indexPath.row])
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "updatespecimendetails", sender: self)
    }
    
}
