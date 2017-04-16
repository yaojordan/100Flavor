//
//  WalkthroughContentViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/4.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

/*這個類別是要用來支援多導覽畫面*/
class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    //自訂的頁籤
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    var index = 0//目前頁面的索引
    var heading = ""
    var imageFile = ""
    var content = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.currentPage = index
        headingLabel.text = heading
        contentLabel.text = content
        contentImageView.image = UIImage(named: imageFile)
        
        switch index {
        case 0...1:
            forwardButton.setTitle("NEXT", for: .normal)
        case 2:
            forwardButton.setTitle("DONE", for: .normal)
        default:
            break
        }
    }
    
    @IBAction func nextButtonTapped(sender: UIButton){
        switch index {
        case 0...1:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
        case 2:
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            dismiss(animated: true, completion: nil)
            
            /*3Dtouch快捷功能，要等使用者導覽後才能啟用，因此放在這裡*/
            if traitCollection.forceTouchCapability == UIForceTouchCapability.available{
                let bundleID = Bundle.main.bundleIdentifier
                let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleID).NewRestaurant", localizedTitle: "New Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
                let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleID).OpenDiscober", localizedTitle: "Discover Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName:"discover"), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2]
            }
            /*forceTouchCapability，用來指示裝置是否能使用3D Touch*/
        default:
            break
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
