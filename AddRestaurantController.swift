//
//  AddRestaurantController.swift
//  100Flavor
//
//  Created by 姚宇鴻 on 2017/4/3.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddRestaurantController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var restaurant:RestaurantMO!//coredata
    var isVisited = false
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBAction func saveButtonTapped(sender: AnyObject)
    {
        if nameTextField.text == ""
        {
            let alertMessage = UIAlertController(title: "Oops!", message: "要填寫店名喔", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        else{
            //coredata
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate)//為了使用persistentContainer，須取得appdelegate的參照
            {
                restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                restaurant.name = nameTextField.text
                restaurant.type = typeTextField.text
                restaurant.location = locationTextField.text
                restaurant.phone = phoneTextField.text
                restaurant.isVisited = isVisited
            
                if let restaurantImage = photoImageView.image{
                    if let imageData = UIImagePNGRepresentation(restaurantImage){
                        restaurant.image = NSData(data: imageData)//image是NSData型態。取得圖片、轉換為NSData
                    }
                }
                appDelegate.saveContext()
                saveRecordToCloud(restaurant: restaurant)//存到icloud
                dismiss(animated: true, completion: nil)//解除
            }
           
        }
    }
    
    
    @IBAction func toggleBeenHereButton(sender: UIButton){
        if sender == yesButton{
            isVisited = true
            yesButton.backgroundColor = UIColor.red
            noButton.backgroundColor = UIColor.lightGray
        }else if sender == noButton{
            isVisited = false
            yesButton.backgroundColor = UIColor.lightGray
            noButton.backgroundColor = UIColor.red

        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*偵測觸控並載入照片庫，第一個cell被選取(row=0)即是開照片庫*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
           if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
           {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                    
                self.present(imagePicker, animated: true, completion: nil)
           }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        /*系統會傳遞包含所選圖片的info字典物件。
         UIImagePickerControllerOriginalImage，使用者所選圖片的鍵*/
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage{
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        /*利用程式碼定義約束條件*/
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: photoImageView.superview, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        
        dismiss(animated: true, completion: nil)//關閉圖片選擇器
    }

    
    /*資料傳到icloud*/
    func saveRecordToCloud(restaurant: RestaurantMO!) -> Void {
        
        //準備要儲存的紀錄
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        
        let imageData = restaurant.image as! Data
        
        //調整圖片大小
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scledImage = UIImage(data: imageData, scale: scalingFactor)!
        
        //將圖片寫進本地端檔案作為暫時的使用
        let imageFilePath = NSTemporaryDirectory() + restaurant.name!//NSTemporaryDirectory取得暫時的路徑
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        try? UIImageJPEGRepresentation(scledImage, 0.8)?.write(to: imageFileURL)//UIImageJPEGRepresentation壓縮圖片資料，write儲存
        
        //建立要上傳的圖片素材
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        
        //讀取public iCloud
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        //儲存至icloud
        publicDatabase.save(record, completionHandler: { (record, error) -> Void in
            
            //移除暫存檔
            try? FileManager.default.removeItem(at: imageFileURL)
        })
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
