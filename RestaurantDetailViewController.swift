//
//  RestaurantDetailViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var restaurant:RestaurantMO!//coredata
    
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
            case "great": restaurant.rating = "覺得超讚！"
            case "good": restaurant.rating = "還算喜歡。"
            case "dislike": restaurant.rating = "不喜歡。"
            default: break
            }
        }
        //更新評價
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            appDelegate.saveContext()
        }
        tableView.reloadData()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /*滑動效果，顯示導覽列，不打算使用，所以設定false*/
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
                
                /*在地圖上加大頭針*/
                //加上標註
                let annotation = MKPointAnnotation()//將座標指定在標註物件內
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
    }

    func showMap(){
        performSegue(withIdentifier: "showMap", sender: self)
        /*showMap方法的實作，觸發這個segue*/
    }
    
    /* 實作UITableViewDataSource協定中必要的方法來填入餐廳資訊，回傳5列餐廳資訊 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantDetailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "店名"
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = "營業時間"
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "地址"
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "電話"
            cell.valueLabel.text = restaurant.phone
        case 4:
            cell.fieldLabel.text = "去過了嗎？"
            if(restaurant.isVisited){
                /*多加這個條件式，否則新增餐廳時選擇"YES"會出錯*/
                if(restaurant.rating == nil){
                cell.valueLabel.text = "去過了"
                }
                else{
                    cell.valueLabel.text = "去過了, \(restaurant.rating!)"
                }
                
            }else{
                cell.valueLabel.text = "還沒去過"
            }
            //cell.valueLabel.text = (restaurant.isVisited) ? "去過了, \(restaurant.rating!)" : "還沒去過"
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
