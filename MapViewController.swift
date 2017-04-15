//
//  MapViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/3.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var restaurant:RestaurantMO!//coredata
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self//定義mapView的delegate。要先採用MKMapViewDelegate協定

        mapView.showsScale = true//顯示縮放比例

        
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
                annotation.title = self.restaurant.name
                annotation.subtitle = self.restaurant.type
                
                if let location = placemark.location{
                    
                    annotation.coordinate = location.coordinate
                    /*將大頭針加到地圖上*/
                    /*showAnnotations可以自動判斷放置大頭真的合適位置。預設不會顯示標註泡泡，所以用selectAnnotation顯示*/
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated:  true)
                    
                    //設定縮放
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)//半徑1000m的範圍
                    self.mapView.setRegion(region, animated: false)
                }
            }
        })

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        /*確認annotation物件是否為MKUserLocation，是則回傳nil，地圖繼續顯示user的當前位置*/
        if annotation.isKind(of: MKUserLocation.self){
            return nil
        }
        
        /*與UITableView類似，重複使用現有的標註*/
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        /*若沒有現有的，就弄一個新的*/
        if annotationView == nil{
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        /*圖顯示在泡泡的左邊*/
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 53, height: 53))
        leftIconView.image = UIImage(data: restaurant.image as! Data)
        annotationView?.leftCalloutAccessoryView = leftIconView
        
        return annotationView
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
