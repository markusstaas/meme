//
//  ViewController.swift
//  Meme Generator V1
//
//  Created by Markus Staas on 3/6/17.
//  Copyright © 2017 Markus Staas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    
    

    //MARK: Set text attributes
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -5.0
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topField.delegate = self
        topField.defaultTextAttributes = memeTextAttributes
        topField.text = "TOP"
        topField.textAlignment = .center
        self.bottomField.delegate = self
        bottomField.defaultTextAttributes = memeTextAttributes
        bottomField.text = "BOTTOM"
        bottomField.textAlignment = .center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       unsubscribeFromKeyboardNotifications()
    }
    
   
    
    //MARK: Choose image
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shootAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.image = image
        }
        dismiss(animated: true, completion: nil)
        
    }
 
    //MARK: Text editing
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField.tag == 1{
            if topField.text == "TOP"{
                topField.text = ""
            }
        }
        if textField.tag == 2{
            if bottomField.text == "BOTTOM"{
                bottomField.text = ""
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1{
            topField.resignFirstResponder()
        }
        if textField.tag == 2{
            bottomField.resignFirstResponder()
        }
        
        return true;
        
    }
    
    
    //MARK: Move view
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomField.isFirstResponder{
            self.view.frame.origin.y =  getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(){
        view.frame.origin.y = 0
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
 //MARK: Create MEME Object
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topField.text!, bottomText: bottomField.text!, originalImage: pickedImage.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    
   }

