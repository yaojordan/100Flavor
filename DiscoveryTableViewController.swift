//
//  DiscoveryTableViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/5.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import CloudKit

class DiscoveryTableViewController: UITableViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var restaurants:[CKRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.stopAnimating()

        fetchRecordsFromCloud()
        /*移除多餘的格線*/
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    func fetchRecordsFromCloud() {
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        //以query建立查詢操作
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "image"]
        queryOperation.queuePriority = .veryHigh//執行順序
        queryOperation.resultsLimit = 50//回傳最大數量
        
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
        }
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if let error = error {
                print("拿資料失敗幫QQ - \(error.localizedDescription)")
                return
            }
            
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()//spinner結束
                self.tableView.reloadData()
            }
            
        }
        
        //執行查詢
        publicDatabase.add(queryOperation)
        
//        publicDatabase.perform(query, inZoneWith: nil, completionHandler: {
//            (results, error) -> Void in
//            
//            if error != nil {
//                print("error to get data on cloud Q_Q")
//                return
//            }
//            
//            if let results = results {
//                self.restaurants = results
//                /*把表格重新載入的動作放到main thread，讓他即時顯示*/
//                OperationQueue.main.addOperation {
//                    self.tableView.reloadData()
//
//                }
//            }
//        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let restaurant = restaurants[indexPath.row]
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
        
        if let image = restaurant.object(forKey: "image"){
            let imageAsset = image as! CKAsset
            
            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL){
                cell.imageView?.image = UIImage(data: imageData)
            }
        }

        return cell
    }
    

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
