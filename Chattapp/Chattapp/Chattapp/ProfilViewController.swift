//
//  ProfilViewController.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 15.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit
import Firebase

class ProfilViewController: UIViewController {

    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBAction func kapat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePhoto.layer.cornerRadius = (imagePhoto.frame.width) / 2 
        
        let dataBaseRef = Database.database().reference()
        let auth = Auth.auth()
        
        dataBaseRef.child(Child.USERS).queryOrdered(byChild: "uid").queryEqual(toValue: auth.currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children
            {
                let snap = child as! DataSnapshot
                let dict = snap.value as! NSDictionary
                
                let name = dict ["name"] as? String
                let photoUrl = dict["photoUrl"] as! String
                
                self.labelInfo.text = name
                Helper.imageLoad(imageView: self.imagePhoto, url: photoUrl)
            }
        }
    }

}
