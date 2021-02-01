//
//  ViewController.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 13.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var buttonGiris: UIButton!
    @IBOutlet weak var buttonKaydol: UIButton!
    @IBOutlet weak var textMail: UITextField!
    @IBOutlet weak var textSifre: UITextField!
    @IBAction func giris(_ sender: Any) {
        
        let email = textMail.text!
        let sifre = textSifre.text!
        
        if email.isEmpty || sifre.isEmpty
        {
            Helper.dialogMessage(message: "Tüm alanları doldurduğunuzdan emin olunuz.", vc:self)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: sifre) { (userData, error) in
            if error != nil
            {
                Helper.dialogMessage(message: "Giriş Yapılamadı", vc: self)
                return
            }else
            {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeViewController") as! HomeViewController
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textSifre.isSecureTextEntry = true
        buttonGiris.layer.cornerRadius = 15
        buttonKaydol.layer.cornerRadius = 15
        textMail.layer.cornerRadius = 50
        textSifre.layer.cornerRadius = 50
        
        // Do any additional setup after loading the view.
        
    }


}

