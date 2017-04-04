//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/2.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
    /*圖片設定成與餐廳相同。從detailviewcontroller傳來*/
    @IBOutlet var containerViewImage: UIImageView!
    var restaurant:RestaurantMO?//coredata
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*圖片設定成與餐廳相同。從detailviewcontroller傳來*/
        if let restaurant = restaurant {
            containerViewImage.image = UIImage(data: restaurant.image as! Data)
            backgroundImageView.image = UIImage(data: restaurant.image as! Data)
        }
        
        /*背景圖片視覺模糊的效果*/
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)//dark,light,extralight
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        /*初次載入時縮小，接著viewdidappear開始動畫*/
        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)

    }
    
    /*動畫時間為0.3sec，CGAffineTransform.identity重新設定view變回原本的大小*/
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
