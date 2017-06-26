//
//  MemeViewControllerExtensions.swift
//  MemeYou
//
//  Created by Francis Gutierrez on 6/25/17.
//  Copyright © 2017 Francis Gutierrez. All rights reserved.
//

import Foundation
import UIKit

extension MemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = editedImage
            
        } else  if let img = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.imageView.image = img
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
        if imageView.image != nil {
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
}

extension MemeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let placeholder = textField.placeholder, textField.text == placeholder {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let placeholder = textField.placeholder, textField.text == "" {
            textField.text = placeholder
        }
    }
}

extension MemeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontDataSource.count
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setTextAttributes(UIFont(name: fontDataSource[row], size: selectedFontSize))
    }
}
