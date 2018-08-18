//
//  SignUpVC.swift
//  Evgegram
//
//  Created by EVGENY SIAGIN on 24.02.2018.
//  Copyright © 2018 EVGENY SIAGIN. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper


class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImagePicker: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    var UserUid: String!
    var emailField: String!
    var passwordField: String!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var username: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            performSegue(withIdentifier: "toMessage", sender: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            userImagePicker.image = image
            
            imageSelected = true
        } else {
            print("фото не выбрано")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUser(img: String) {
        let userData = [
            "username": username!,
            "userImg": img
        ]
        KeychainWrapper.standard.set(UserUid, forKey: "uid")
        let location = Database.database().reference().child("users").child(UserUid)
        location.setValue(userData)
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImg() {
        if usernameField.text == nil {
            signUpBtn.isEnabled = false
        } else {
            username = usernameField.text
            signUpBtn.isEnabled = true
        }
        
        guard let img = userImagePicker.image, imageSelected == true else {
            print ("нужно выбрать фото")
            return
        }
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/ipeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("фото не загружено")
                } else {
                    print("фото загружено")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.setUser(img: url)
                    }
                }
            }
        }
    }
    
    @IBAction func createAccount (_ sender: AnyObject) {
        Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: { (user, error) in
            if error != nil {
                print("Не удалось создать пользователя")
            } else {
                if let user = user {
                    self.UserUid = user.uid
                }
            }
            self.uploadImg()
        })
    }
    
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel (_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}



















