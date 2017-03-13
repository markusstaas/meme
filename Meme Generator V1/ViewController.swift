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
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var memedImage: UIImage!
    

    //MARK: Set text attributes
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "Impact", size: 40)!,
        NSStrokeWidthAttributeName: -5.0
    ]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createTextFields(textField: topField, defaultText: "TOP")
        createTextFields(textField: bottomField, defaultText: "BOTTOM")
        
    }
    
    func createTextFields(textField: UITextField, defaultText: String){
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
       unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        pickedImage.image = nil
        topField.text = "TOP"
        bottomField.text = "BOTTOM"
    }
   
    
    //MARK: Choose image
    @IBAction func pickAnImage(_ sender: Any) {
       presentImagePicker(chosenSource: .photoLibrary)
        }
    
    @IBAction func shootAnImage(_ sender: Any) {
       presentImagePicker(chosenSource: .camera)
        }
    
    func presentImagePicker(chosenSource: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = chosenSource
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
        
        return true
        
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
            pickedImage.contentMode = .scaleAspectFill
        }
    }
    
    func keyboardWillHide(){
        view.frame.origin.y = 0
        pickedImage.contentMode = .scaleAspectFit
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
 //MARK: Create MEME Object
    
    struct Meme{
        var topText: String?
        var bottomText: String?
        var originalImage: UIImage?
        var memedImage: UIImage!
    }
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topField.text!, bottomText: bottomField.text!, originalImage: pickedImage.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        navBar.isHidden = true
        toolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        self.memedImage = generateMemedImage()
        let shareMeme = UIActivityViewController(activityItems: [self.memedImage], applicationActivities: nil)
        
        // Save image to shared
        shareMeme.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.present(shareMeme, animated: true, completion: nil)
        
    }
    
    
    
   }

