//
//  ViewController.swift
//  MemeYou
//
//  Created by Francis Gutierrez on 6/5/17.
//  Copyright © 2017 Francis Gutierrez. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {

    @IBOutlet weak var camarabtn: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var baseText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var picker: UIPickerView!
    
    var fontDataSource : [String] = UIFont.familyNames.sorted { $0 < $1 }
    var selectedFontFamily = "Futura"
    var selectedFontSize: CGFloat = 40.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camarabtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        let shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
        navigationItem.leftBarButtonItem = shareBtn
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        let cancelBtn = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(resetEditor))
        let settingsBtn = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(showSettings))
        navigationItem.rightBarButtonItems = [cancelBtn,settingsBtn]
        
        if let font = UIFont(name: "Futura", size: 21.0) {
            settingsBtn.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        }
        
        picker.delegate = self
        
        setTextAttributes(UIFont(name: selectedFontFamily, size: selectedFontSize))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setTextAttributes(_ fontAttribute: UIFont?) {
        if let fontAttribute = fontAttribute {
            let memeTextAttributes:[String:Any] = [
                NSStrokeColorAttributeName: UIColor.black,
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: fontAttribute,
                NSStrokeWidthAttributeName: -5.0
            ]
            
            topText.defaultTextAttributes = memeTextAttributes
            topText.textAlignment = .center
            
            baseText.defaultTextAttributes = memeTextAttributes
            baseText.textAlignment = .center
        }
    }


    @IBAction func camaraAction(_ sender: Any) {
        chooseSourceType(.camera)
    }
    
    @IBAction func photoLibraryAction(_ sender: Any) {
        chooseSourceType(.photoLibrary)
    }
    
    func chooseSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        controller.allowsEditing = true
        present(controller, animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if baseText.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if view.frame.origin.y < 0 {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func shareAction() {
        // Create the meme
        let memedImage = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        
        activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, items: [Any]?, error: Error?) in
            if (completed) {
                self.save(memedImage)
            }
        }
            
        present(activityController, animated: true, completion: nil)
    }
    
    func resetEditor() {
        imageView.image = nil
        topText.text = topText.placeholder!
        baseText.text = baseText.placeholder!
        view.frame.origin.y = 0
        picker.alpha = 0.0
        picker.selectRow(29, inComponent: 0, animated: false)
        selectedFontFamily = "Futura"
        setTextAttributes(UIFont(name: selectedFontFamily, size: selectedFontSize))
        
        topText.resignFirstResponder()
        baseText.resignFirstResponder()
    }
    
    func showSettings() {
        picker.alpha = picker.alpha > 0 ? 0.0 : 0.7
    }
    
    func save(_ memedImage: UIImage) {
        let meme = Meme(topText: topText.text!, bottomText: baseText.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        print(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        displayToolBars(false)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        displayToolBars()
        return memedImage
    }
    
    func displayToolBars(_ shouldDisplay:Bool = true) {
        toolBar.alpha = shouldDisplay ? 1.0 : 0.0
        navigationController?.navigationBar.alpha = shouldDisplay ? 1.0 : 0.0
        picker.alpha = 0.0
    }

}
