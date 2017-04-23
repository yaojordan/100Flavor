//
//  RestaurantTableViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIViewControllerPreviewingDelegate {
    
    var restaurants:[RestaurantMO] = []//coredata託管物件，透過它來修改實體的內容
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
        //解除segue
    }
    
    /**/
    //    var searchController: UISearchController!
    //    var searchResults:[RestaurantMO] = []
    /**/
    /*搜尋功能，filter過濾目前陣列。*/
    /*搜尋有問題，需要再檢查與調整*/
//    func filterContent(for searchText: String){
//        searchResults = restaurants.filter({(restaurant) -> Bool in
//            if let name = restaurant.name{
//                let isMatch = name.localizedCaseInsensitiveContains(searchText)
//                return isMatch
//            }
//            return false
//        })
//    }
    
    /*使用者選取搜尋列會呼叫此方法*/
//    func updateSearchResults(for searchController: UISearchController) {
//        if let searchText = searchController.searchBar.text{
//            filterContent(for: searchText)//取得搜尋的文字，傳給filtercontent
//            tableView.reloadData()
//        }
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        

        /*加入searchbar*/
//        searchController = UISearchController(searchResultsController: nil)
//        tableView.tableHeaderView = searchController.searchBar
//        
//        searchController.searchResultsUpdater = self//指定目前類別為搜尋結果更新器
//        searchController.dimsBackgroundDuringPresentation = false
//        
//        searchController.searchBar.placeholder = "Search restaurants..."
//        searchController.searchBar.tintColor = UIColor.white
        
        /*3D touch，先檢查是否支援，然後註冊預覽功能*/
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        /*啟用自適應cell，需搭配storyboard的auto layout*/
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /*讓導覽列的返回按鈕不顯示標體，只顯示箭頭*/
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        /*Fetch*/
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)//依名稱排序
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appdelegate = (UIApplication.shared.delegate as? AppDelegate){
            let context = appdelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do{
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects{
                    restaurants = fetchedObjects
                }
            }catch{
                print("Fetch error")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*滑動時隱藏導覽列。覺得效果不是很好所以不打算使用*/
        //navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough"){
            return
        }
            
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController")
                as? WalkthroughPageViewController{
                present(pageViewController, animated: true, completion: nil)
        }
        
    }

    /**/
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()//告訴tableview，要準備更新內容了
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
        case .insert:
            if let newIndexPath = newIndexPath{
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath{
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        if let fetchObjects = controller.fetchedObjects{
            restaurants = fetchObjects as! [RestaurantMO]
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()//更新完成囉
    }
    /**/
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchController.isActive{//決定tableview應該顯示全部或是搜尋結果
//            return searchResults.count
//        }else{
//            return restaurants.count
//        }
       return restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
        /* 
        as!強制轉型，讓物件從RestaurantTableViewCell回傳
        原先是UITableViewCell，但我們在這使用自訂的Cell，
        也就是RestaurantTableViewCell。
         */
        
//        let restaurant = (searchController.isActive) ? searchResults[indexPath.row]: restaurants[indexPath.row]

        //設定cell呈現的內容
        cell.nameLabel.text = restaurants[indexPath.row].name
        cell.locationLabel.text = restaurants[indexPath.row].location
        cell.typeLabel.text = restaurants[indexPath.row].type
        cell.thumbnailImageView.image = UIImage(data: restaurants[indexPath.row].image as! Data)
        
        /* 檢查是否有勾選，若為true，則更新輔助示圖(accessory type)為打勾 */
        if restaurants[indexPath.row].isVisited{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if searchController.isActive{
//            return false
//        }else{
//            return true
//        }
//    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        
        //社群分享按鈕
        /*包含自動載入的文字與圖片*/
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                               title: "分享", handler:{(action, indexPath) -> Void in
            let defaultText = "在 " + self.restaurants[indexPath.row].name! + " 打卡"
            if let imageToShare = UIImage(data: self.restaurants[indexPath.row].image as! Data)
            {
              let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
              self.present(activityController, animated: true, completion: nil)
            }
        })
        
        //刪除按鈕
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                                title: "刪除", handler:{(action, indexPath) -> Void in
            
            /*必須確實將資料從資料庫移除，否則下次開啟時還會出現*/
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
            {
                let context = appDelegate.persistentContainer.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                appDelegate.saveContext()//儲存變更
            }
                                                    
        })
        shareAction.backgroundColor = UIColor.init(red: 48.0/255.0, green: 48.0/255.0, blue: 99.0/255.0, alpha: 1)//亂調的顏色
        return [deleteAction, shareAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        /*檢查segue, 只對showRestaurantDetail這個segue執行*/
        if segue.identifier == "showRestaurantDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! RestaurantDetailViewController
                
                //destinationController.restaurant = (searchController.isActive) ? searchResults[indexPath.row]: restaurants[indexPath.row]
                
                destinationController.restaurant = restaurants[indexPath.row]
            }
        }
    }
    
    /*3D touch peek and pop實作*/
    //觸控以CGPoint型態進行參數傳遞，推導出哪個cell被選取
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint)-> UIViewController?{
        guard let indexPath = tableView.indexPathForRow(at: location)//以取得的點，回傳該點所在列的路徑
            else{
                return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath)
            else{
                return nil
        }
        
        guard let restaurantDetailViewController = storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController//使用storyboard識別碼
            else{
                return nil
        }
        
        let selectedRestaurant = restaurants[indexPath.row]
        restaurantDetailViewController.restaurant = selectedRestaurant
        restaurantDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)//可以不設定，會自動以預設尺寸呈現
        
        previewingContext.sourceRect = cell.frame//預覽內容的cell要保持清楚
        
        return restaurantDetailViewController
    }
    //pop部分，提交一個viewcontroller，呼叫showViewController來呈現。
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController){
        show(viewControllerToCommit, sender: self)
    }
    /*3D touch部分結束*/

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
