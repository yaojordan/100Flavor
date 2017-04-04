//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
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
        //更新評價
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            appDelegate.saveContext()
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
    
    var restaurant:RestaurantMO!//coredata
    
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
        
        /*取消這個，才能讓地圖顯示出來
        tableView.tableFooterView = UIView(frame: CGRect.zero)//透過tableFooterView移除空白列的分隔線
         */
        
        /*地理編碼器，將地址轉換為座標。並在地圖上標註位置*/
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location!, completionHandler: {
        placemarks, error in
            if error != nil{
                print("error")
                return
            }
            
            if let placemarks = placemarks{
                //取得第一個地標
                let placemark = placemarks[0]
                
                //加上標註
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location{
                    //顯示標註
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    //設定縮放
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)//半徑1000m的範圍
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })
        /*偵測點擊手勢，呼叫target的方法是showMap*/
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)//分隔線顏色
        
        restaurantImageView.image = UIImage(data: restaurant.image as! Data)
//        restaurantNameLabel.text = restaurant.name
//        restaurantLocationLabel.text = restaurant.location
//        restaurantTypeLabel.text = restaurant.type
    }

    func showMap(){
        performSegue(withIdentifier: "showMap", sender: self)
        /*showMap方法的實作*/
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
    
    /*要把restaurant傳到reviewviewcontroller，或是mapviewcontroller*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReviewView"
        {
                let destinationController = segue.destination as! ReviewViewController
                destinationController.restaurant = restaurant
        }
        else if segue.identifier == "showMap"
        {
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
