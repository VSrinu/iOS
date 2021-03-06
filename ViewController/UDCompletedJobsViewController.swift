//
//  UDCompletedJobsViewController.swift
//  oogioogi
//
//  Created by ARXT Labs on 10/4/18.
//  Copyright © 2018 ARXT Labs. All rights reserved.
//

import UIKit
import Material

class UDCompletedJobsViewController: UIViewController {
    @IBOutlet weak var toolBar: Toolbar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    fileprivate var backButton: IconButton!
    let refreshControl = UIRefreshControl()
    var myJobsArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        self.loadInitialData()
    }
    
    // MARK:- View Lifecycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getMyCompletedJobs()
    }
    
    func loadInitialData() {
        let data = UserDefaults.standard.object(forKey:"userInfo") as! Data
        userInfoDictionary = (NSKeyedUnarchiver.unarchiveObject(with: data) as! NSMutableDictionary?)!
        prepareBackButton()
        prepareToolbar()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 43
        self.tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
        ConstantTools.sharedConstantTool.showsMRIndicatorView(self.view,text: "fetching your job details")
    }
    
    @objc func didPullToRefresh() {
        getMyCompletedJobs()
    }
    
    func getMyCompletedJobs() {
        let merchantId = userInfoDictionary.object(forKey: "merchantid") as? Int ?? 0
        let userId = userInfoDictionary.object(forKey: "carrierid") as? Int ?? 0
        OrdersModel.getMyCompletedOrdersDetails(acceptedby: userId, merchantId: merchantId) { connectionResult in
            DispatchQueue.main.async(execute: {() -> Void in
                ConstantTools.sharedConstantTool.hideMRIndicatorView()
                self.refreshControl.endRefreshing()
                switch connectionResult {
                case .success(let data):
                    self.myJobsArray = data
                    self.noDataLabel.isHidden = true
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                case .failure(let error):
                    self.noDataLabel.isHidden = false
                    self.tableView.isHidden = true
                    self.view.makeToast(error, position: .top)
                }
            })
        }
    }
}

// MARK:- ToolBar
extension UDCompletedJobsViewController {
    fileprivate func prepareBackButton() {
        backButton = IconButton(image: Icon.cm.arrowBack, tintColor: .white)
        backButton.pulseColor = .white
        backButton.addTarget(self, action: #selector(navigateBack(button:)), for: .touchUpInside)
    }
    
    fileprivate func prepareToolbar() {
        toolBar.titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        toolBar.titleLabel.textAlignment = .left
        toolBar.leftViews = [backButton]
    }
    
    @objc
    fileprivate func navigateBack(button: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK:- UITableViewDataSource
extension UDCompletedJobsViewController: UITableViewDataSource, UITableViewDelegate {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myJobsArray.count
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 6
        }
        return 0.0001
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myJobCell", for: indexPath) as! UDLandingCell
        let jobDict:NSDictionary = myJobsArray[indexPath.row] as! NSDictionary
        let orderId = jobDict.object(forKey: "orderid") as? Int ?? 0
        cell.jobIdLabel.text = "\(orderId)"
        let preferreddeliverytime = jobDict.object(forKey: "preferreddeliverytimeoffset") as? Date ?? Date()
        let deliverDate = ConstantTools.sharedConstantTool.dayFormat(date: preferreddeliverytime)
        cell.deliveryDate.text = deliverDate
        let deliverMonth = ConstantTools.sharedConstantTool.monthFormat(date: preferreddeliverytime)
        cell.deliveryMonth.text = deliverMonth
        let time = ConstantTools.sharedConstantTool.timeFormat(date: preferreddeliverytime)
        cell.deliveryTime.text = time
        let customerName = jobDict.object(forKey: "customername") as? String ?? ""
        let city = jobDict.object(forKey: "city") as? String ?? ""
        cell.jobDetails.text = "Delivered to \(customerName) at \(city)"
        cell.distanceFromStore.text = "From Store: \(jobDict.object(forKey: "storetocustlocation") as? Double ?? 0.0) Miles"
        cell.distanceFromeAddress.text = "From your Address: \(jobDict.object(forKey: "carriertocustlocation") as? Double ?? 0.0) Miles"
        let address = jobDict.object(forKey: "address") as? String ?? ""
        let state = jobDict.object(forKey: "state") as? String ?? ""
        let zip = jobDict.object(forKey: "zip") as? String ?? ""
        cell.activeCarriers.text = "Address: \(address), \(city), \(state), \(zip)"
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let jobDict:NSDictionary = myJobsArray[indexPath.row] as! NSDictionary
        let storyboard = UIStoryboard(name: "iPhoneStoryboard", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UDCompletedJobDetailsViewController") as! UDCompletedJobDetailsViewController
        viewController.myJobDict = jobDict
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
