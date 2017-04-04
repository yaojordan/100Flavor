//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
        //解除segue
    }
    //var restaurantIsVisited = Array(repeating: false, count: 21)//21個資料初始都是false，未打勾的狀態
    
    var restaurants:[RestaurantMO] = []//coredata
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    
    var searchController: UISearchController!
    var searchResults:[RestaurantMO] = []
    /*搜尋功能，filter過濾目前陣列。*/
    func filterContent(for searchText: String){
        searchResults = restaurants.filter({(restaurant) -> Bool in
            if let name = restaurant.name{
                let isMatch = name.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    /*使用者選取搜尋列會呼叫此方法*/
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            filterContent(for: searchText)//取得搜尋的文字，傳給filtercontent
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*隱藏導覽列*/
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*加入searchbar*/
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.tintColor = UIColor.white

        
        /*啟用自適應cell，需搭配storyboard的auto layout*/
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /*移除導覽列的返回按鈕標體*/
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        /*Fetch*/
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive{//決定tableview應該顯示全部或是搜尋結果
            return searchResults.count
        }else{
            return restaurants.count
        }
       
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
        
        let restaurant = (searchController.isActive) ? searchResults[indexPath.row]: restaurants[indexPath.row]

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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive{
            return false
        }else{
            return true
        }
    }
 
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        tableView.deselectRow(at: indexPath, animated: false)//選取cell時不會卡灰色
//        
//        /* 建立一個選單，preferredStyle: .actionSheet為選單，若使用.alert則為彈框 */
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//        
//        /*撥打電話失敗的處理*/
//        let callActionHandler = { (action:UIAlertAction!) -> Void in
//            let alertMessage = UIAlertController(title:"Service Unavailable", message:"Sorry, 打不通, 滾吧！", preferredStyle:.alert)
//            alertMessage.addAction(UIAlertAction(title:"OK", style:.default, handler:nil))
//            self.present(alertMessage, animated: true, completion: nil)
//        }
//        
//        
//        //加入動作Check in
//        let checkInAction = UIAlertAction(title: "Check in", style: .default, handler:
//        {
//            (action:UIAlertAction!)->Void in
//            let cell = tableView.cellForRow(at: indexPath)//indexpath取得所選取的cell
//            cell?.accessoryType = .checkmark//更新該cell的accessoryType，顯示checkmark
//            self.restaurantIsVisited[indexPath.row] = true
//        })
//        //加入動作undo Check in
//        let undoCheckInAction = UIAlertAction(title: "Undo Check in", style: .default, handler:
//        {
//            (action:UIAlertAction!)->Void in
//            let cell = tableView.cellForRow(at: indexPath)//indexpath取得所選取的cell
//            cell?.accessoryType = .none//更新該cell的accessoryType，checkmark消失
//            self.restaurantIsVisited[indexPath.row] = false
//        })
//        //加入動作Call
//        let callAction = UIAlertAction(title: "Call"+" 123-000-\(indexPath.row)", style: .default, handler: callActionHandler)
//        //加入動作cancel
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        optionMenu.addAction(callAction)
//        optionMenu.addAction(cancelAction)
//        
//        /*
//         如果是false的狀態，可以選擇check-in按鈕
//         若已經是選取(true)，則會顯示undo check-in
//         */
//        if restaurantIsVisited[indexPath.row]{
//            optionMenu.addAction(undoCheckInAction)
//        }else{
//            optionMenu.addAction(checkInAction)
//        }
//        
//        //呈現選單
//        present(optionMenu, animated: true, completion: nil)
//    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        
        //社群分享按鈕
        /*包含自動載入的文字與圖片*/
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                               title: "Share", handler:{(action, indexPath) -> Void in
            let defaultText = "Just check in at " + self.restaurants[indexPath.row].name!
            if let imageToShare = UIImage(data: self.restaurants[indexPath.row].image as! Data)
            {
              let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
              self.present(activityController, animated: true, completion: nil)
            }
        })
        
        //刪除按鈕
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                                title: "Delete", handler:{(action, indexPath) -> Void in
                                                    
            self.restaurants.remove(at: indexPath.row)
           /*
            改用物件的方式就可以不用寫這些
            self.restaurantLocations.remove(at: indexPath.row)
            self.restaurantTypes.remove(at: indexPath.row)
            self.restaurantIsVisited.remove(at: indexPath.row)
            self.restaurantImages.remove(at: indexPath.row)
            */
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            /* 利用比較好看的方式刷新表格視圖.fade, .left, .top皆可 */
            
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
                /*
                destinationController.restaurantImage = restaurantImages[indexPath.row]
                destinationController.restaurantName = restaurantNames[indexPath.row]
                destinationController.restaurantLocation = restaurantLocations[indexPath.row]
                destinationController.restaurantType = restaurantTypes[indexPath.row]
                 */
                destinationController.restaurant = (searchController.isActive) ? searchResults[indexPath.row] :restaurants[indexPath.row]
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
