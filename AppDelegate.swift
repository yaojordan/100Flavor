//
//  AppDelegate.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/1.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /*改變狀態列的顏色(要先去Info把View controller-based...改成No)*/
        UIApplication.shared.statusBarStyle = .lightContent
        
        /*使用Apple導入的Appearance API設定導覽列的外觀、字體*/
        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        if let barFont = UIFont(name: "AvenirNextCondensed-DemiBold", size: 18.0){
            UINavigationBar.appearance().titleTextAttributes =
                [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName:barFont]
        }
        
        // Override point for customization after application launch.
        return true
    }

    /*3D touch快捷應用*/
    //先宣告一個列舉，在case中定義快捷功能，並將完整的識別碼轉換成對應列舉的case
    enum QuickAction:String{
        case NewRestaurant = "NewRestaurant"
        case OpenDiscover = "OpenDiscover"
        
        init?(fullIdentifier: String){
            
            guard let shortcutIdentifier = fullIdentifier.components(separatedBy: ".").last
                else{
                    return nil
            }
            
            self.init(rawValue: shortcutIdentifier)
        }
    }
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        let shortcutType = shortcutItem.type
        guard let shortcutIdentifier = QuickAction(fullIdentifier: shortcutType)
            else{
                return false
        }
        
        guard let tabBarController = window?.rootViewController as? UITabBarController
            else{
                return false
        }
        
        switch shortcutIdentifier {
        case .NewRestaurant:
            if let navController = tabBarController.viewControllers?[0]{
                //從tabbar取得第一個，也就是Restaurant Table View，接著呼叫addRestaurant這個segue，讓他導向頁面
                let restaurantTableViewController = navController.childViewControllers[0]
                restaurantTableViewController.performSegue(withIdentifier: "addRestaurant", sender: restaurantTableViewController)
            }else{
                return false
            }
        case .OpenDiscover:
            tabBarController.selectedIndex = 1 //Discover是tabbar的第二個選項
        }
        return true
    }
    /*3D touch快捷應用結束*/
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "100Flavor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

