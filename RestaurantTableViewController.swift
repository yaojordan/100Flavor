//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
        //解除segue
    }
    //var restaurantIsVisited = Array(repeating: false, count: 21)//21個資料初始都是false，未打勾的狀態
    
    var restaurants:[RestaurantMO] = []

    override func viewWillAppear(_ animated: Bool) {
        /*隱藏導覽列*/
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*啟用自適應cell，需搭配storyboard的auto layout*/
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /*移除導覽列的返回按鈕標體*/
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }


    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                destinationController.restaurant = restaurants[indexPath.row]
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /* Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }*/
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
