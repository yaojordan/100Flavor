//
//  AddRestaurantController.swift
//  FoodPin
//
//  Created by 姚宇鴻 on 2017/4/3.
//  Copyright © 2017年 JordanYao. All rights reserved.
//

import UIKit

class AddRestaurantController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBAction func saveButtonTapped(sender: AnyObject)
    {
        if nameTextField.text == "" || typeTextField.text == "" || locationTextField.text == ""
        {
            let alertMessage = UIAlertController(title: "哎呀!", message: "有些欄位還沒填喔", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        //dismiss(animated: true, completion: nil)
    }
    @IBAction func toggleBeenHereButton(sender: UIButton){
        if sender == yesButton{
            yesButton.backgroundColor = UIColor.red
            noButton.backgroundColor = UIColor.lightGray
        }else if sender == noButton{
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

    /*偵測觸控並載入照片庫，第一個cell被選取(row=0)即是照片庫*/
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
        
        /*系統會傳遞包含所有圖片的info字典物件。
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

    
    
    
    
    
    
    
    
    
    
    
    
    
}