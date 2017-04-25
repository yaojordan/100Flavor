//
//  WalkthroughPageViewController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/4.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

class WalkthroughPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageHeadings = ["個人化", "尋找位置", "探索"]
    var pageImages = ["intro-1", "intro-2", "intro-3"]
    var pageContent = ["記錄您所喜愛的餐廳，建立屬於自己的一百種味道。",
                       "透過地圖功能找到您所喜愛的餐廳位置。",
                       "看看其他人們都吃了些什麼？"]
    
    /*前一個*/
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    /*後一個*/
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> WalkthroughContentViewController?
    {
        if index < 0 || index >= pageHeadings.count{
            return nil
        }
        
        //建立新的viewcontroller，傳遞資料給他
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughContentViewController")
            as? WalkthroughContentViewController{
            
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.content = pageContent[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        return nil
    }
    
    /*以頁面索引呼叫viewcontroller，再使用setViewControllers導覽*/
    func forward(index: Int){
        if let nextViewController = contentViewController(at: index+1){
            setViewControllers([nextViewController], direction: .forward, animated: true,
                               completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self//資料來源為自己
        
        /*建立第一個導覽畫面*/
        if let startingViewController = contentViewController(at: 0){
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
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
