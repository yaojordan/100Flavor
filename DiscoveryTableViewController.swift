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
    var imageCache = NSCache<CKRecordID, NSURL>()//快取物件

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*下拉更新控制*/
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControlEvents.valueChanged)
        
        
        //spinner.hidesWhenStopped = true/*直接從storyboard設定*/
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()

        fetchRecordsFromCloud()
        /*移除多餘的格線*/
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Enable Self Sizing Cell 自適應，依照表格內容調整高度
        tableView.estimatedRowHeight = 249.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    func fetchRecordsFromCloud() {
        
        
        /*更新之前移除現有記錄*/
        restaurants.removeAll()
        tableView.reloadData()
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //按建立時間排序
        
        //以query建立查詢操作
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "type", "location", "image", "phone"]//指定取得的欄位
        queryOperation.queuePriority = .veryHigh//執行順序
        queryOperation.resultsLimit = 50//回傳最大數量
        
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
        }
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if let error = error {
                print("從Cloud取資料失敗 - \(error.localizedDescription)")
               /* let alertMessage = UIAlertController(title: "Oops!", message: "請先登入iCloud才能取用資料。\n 設定 -> iCloud", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))//{(alert: UIAlertAction!) in self.fetchRecordsFromCloud()}))
                self.present(alertMessage, animated: true, completion: nil)*/
                return
            }
            
            OperationQueue.main.addOperation {
                self.spinner.stopAnimating()//spinner結束
                
                self.tableView.reloadData()
                
                /*檢查是否還在更新狀態*/
                if let refreshControl = self.refreshControl{
                    if refreshControl.isRefreshing{
                        refreshControl.endRefreshing()
                    }
                }
            }
            
        }
        
        //執行查詢
        publicDatabase.add(queryOperation)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1//預設就是一個區塊
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantTableViewCell

        //設定Cell
        let restaurant = restaurants[indexPath.row]
        cell.nameLabel.text = restaurant.object(forKey: "name") as? String
        cell.typeLabel.text = restaurant.object(forKey: "type") as? String
        cell.locationLabel.text = restaurant.object(forKey: "location") as? String


        //檢查圖片是否在快取中
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID){
            //從快取中取得圖片
            print("get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL){
                cell.thumbnailImageView.image = UIImage(data: imageData)
            }
            
        }
        else
        {
            //在背景中從雲端取得圖片
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs:[restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
                
            fetchRecordsImageOperation.perRecordCompletionBlock = { (record, recordID, error) -> Void in
                if let error = error {
                    print("取得餐廳圖片失敗： \(error.localizedDescription)")
                    return
                }
                    
                if let restaurantRecord = record
                {
                    OperationQueue.main.addOperation{
                        if let image = restaurantRecord.object(forKey: "image"){
                            let imageAsset = image as! CKAsset
                                
                            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL){
                                cell.thumbnailImageView.image = UIImage(data: imageData)
                                
                            }
                                
                            //加圖片URL至快取中
                            self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                        }
                    }
                }
            }
            
            publicDatabase.add(fetchRecordsImageOperation)
        }

        return cell
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
