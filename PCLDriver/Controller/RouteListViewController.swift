//
//  RouteListViewController.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/8/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import UIKit

class RouteListViewController: UIViewController {

    @IBOutlet weak var routeListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        routeListTableView.delegate = self
        routeListTableView.dataSource = self
        routeListTableView.register(UINib(nibName: "RouteTableViewCell", bundle: .main), forCellReuseIdentifier: "RouteTableViewCell")
        // Do any additional setup after loading the view.
    }

}
extension RouteListViewController : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "updatespecimendetails", sender: self)
    }
    
}
