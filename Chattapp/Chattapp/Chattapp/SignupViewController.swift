//
//  SignupViewController.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 13.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var buttonKaydol: UIButton!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePhoto.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func openGallery()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func kapat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var imagePhoto: UIImageView!
    
    @IBOutlet weak var textName: UITextField!
    
    @IBOutlet weak var textMail: UITextField!
    
    @IBOutlet weak var textSifre: UITextField!
    
    @IBOutlet weak var textSifreTekrar: UITextField!
    
    
    @IBAction func kaydol(_ sender: Any) {
        let name = textName.text!
        let email = textMail.text!
        let sifre = textSifre.text!
        let sifreTekrar = textSifreTekrar.text!
        
        if name.isEmpty || email.isEmpty || sifre.isEmpty || sifreTekrar.isEmpty
        {
            Helper.dialogMessage(message: "Tüm alanları doldurduğunuzdan emin olunuz.", vc: self)
            return
        }
        
        if sifre != sifreTekrar
        {
            Helper.dialogMessage(message: "Şifreler Uyuşmuyor.", vc: self)
            return
        }
        
        let dbRef = Database.database().reference()
        let storageRef = Storage.storage().reference()
        let auth = Auth.auth()
        
        auth.createUser(withEmail: email, password: sifre) { (userData, error) in
            if error != nil
            {
                Helper.dialogMessage(message: "Kaydol İşlemi Başarısız.", vc: self)
                return
            }else
            {
                let imageName = UUID().uuidString + ".jpg"
                let path = "image"
                let imageRef = storageRef.child(path).child(imageName)
                
                imageRef.putData((self.imagePhoto.image?.jpegData(compressionQuality: 0.8))!, metadata: nil, completion: { (metadata, error) in
                    if error != nil
                    {
                        Helper.dialogMessage(message: "Fotoğraf yükleme başarısız", vc: self)
                        return
                    }else
                    {
                        imageRef.downloadURL(completion: { (URL, error) in
                            if error != nil
                            {
                                Helper.dialogMessage(message: "Link Alınamadı", vc: self)
                                return
                            }else
                            {
                                let userData = ["name":name,"email":email,"uid":auth.currentUser!.uid,"photoUrl":URL?.absoluteString]
                            
                                dbRef.child("users").childByAutoId().setValue(userData)
                                
                                
                             
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as!
                                HomeViewController
                                self.present(vc, animated: true, completion: nil)
                            
                            }
                        })
                        
                    }
                })
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textSifre.isSecureTextEntry = true
        textSifreTekrar.isSecureTextEntry = true
        
        
        let action = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        imagePhoto.addGestureRecognizer(action)
        imagePhoto.isUserInteractionEnabled = true
        imagePhoto.layer.cornerRadius = (imagePhoto.frame.width) / 2
        buttonKaydol.layer.cornerRadius = 15
        
    }
}
