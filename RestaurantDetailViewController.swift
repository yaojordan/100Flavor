//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func close(segue:UIStoryboardSegue){
        //這是用來定義解除segue的方法
    }
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue){
        if let rating = segue.identifier{
            
            restaurant.isVisited = true
            
            switch rating {
            case "great": restaurant.rating = "Absolutely love it, must try!"
            case "good": restaurant.rating = "Pretty good."
            case "dislike": restaurant.rating = "I don't like it."
            default: break
            }
        }
        tableView.reloadData()
    }
    
//    @IBOutlet weak var restaurantNameLabel: UILabel!
//    @IBOutlet weak var restaurantLocationLabel: UILabel!
//    @IBOutlet weak var restaurantTypeLabel: UILabel!
    
    //接收傳過來的資料
//    var restaurantImage = ""
//    var restaurantName = ""
//    var restaurantLocation = ""
//    var restaurantType = ""
    
    var restaurant:Restaurant!
    
    override func viewWillAppear(_ animated: Bool) {
        /*滑動效果，顯示導覽列*/
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*啟用自適應cell*/
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.2)//very light gray
        tableView.tableFooterView = UIView(frame: CGRect.zero)//透過tableFooterView移除空白列的分隔線
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)//分隔線顏色
        
        restaurantImageView.image = UIImage(named: restaurant.image)
//        restaurantNameLabel.text = restaurant.name
//        restaurantLocationLabel.text = restaurant.location
//        restaurantTypeLabel.text = restaurant.type
    }

    /* 
     實作UITableViewDataSource協定中必要的方法來填入餐廳資訊，回傳4列餐廳資訊
     依照課本練習增加一列phone，共5列
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantDetailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "Type"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "Phone"
            cell.valueLabel.text = restaurant.phone
        case 4:
            cell.fieldLabel.text = "Been here"
            cell.valueLabel.text = (restaurant.isVisited) ? "Yes, I've been here before \(restaurant.rating)" : "No"
            /*結合評價的內容*/
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        cell.backgroundColor = UIColor.clear//讓cell變透明，如此就可以呈現tableView的背景色
        return cell
    }
    
    /*要把restaurant傳到reviewviewcontroller*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReviewView"{
                let destinationController = segue.destination as! ReviewViewController
                destinationController.restaurant = restaurant
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
