//
//  AppDelegate.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 13.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func kapat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataBaseRef.child(Child.CHAT_INBOX).child(String(self.list[indexPath.row].rowKey!)).child("okundu").setValue("0")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "talkViewController") as! TalkViewController
        vc.aliciUid = self.list[indexPath.row].uid!
        vc.aliciName = self.list[indexPath.row].name!
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profilCell") as! TableViewCell
        
        let info = self.list[indexPath.row]
        cell.labelName.text = info.name
        Helper.imageLoad(imageView: cell.imagePhoto, url: info.photoUrl!)
        
        cell.imagePhoto.layer.cornerRadius = (cell.imagePhoto.frame.width) / 2
        cell.imagePhoto.clipsToBounds = true
        cell.imagePhoto.layer.borderWidth = 3.0
        
        if info.okundu == "1"{
            cell.imagePhoto.layer.borderColor = UIColor.green.cgColor
        }else{
            cell.imagePhoto.layer.borderColor = UIColor.white.cgColor
        }
        
        return cell
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    var list = [ListItem]()
    
    var dataBaseRef:DatabaseReference!
    var auth:Auth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBaseRef = Database.database().reference()
        auth = Auth.auth()
        
        self.tableLoad()
    }
    
    func tableLoad(){
        dataBaseRef.child(Child.CHAT_INBOX)
            .queryOrdered(byChild: "gonderenUid")
            .queryEqual(toValue: self.auth.currentUser!.uid).observe(.value) { (snapshot) in
                self.list.removeAll()
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    
                    let rowKey = snap.key
                    let aliciUid = dict["aliciUid"] as! String
                    let okundu = dict["okundu"] as! String
                    
                    self.dataBaseRef.child(Child.USERS)
                        .queryOrdered(byChild: "uid")
                        .queryEqual(toValue: aliciUid).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            for child in snapshot.children{
                                let snap = child as! DataSnapshot
                                let dict = snap.value as! NSDictionary
                                
                                let name = dict["name"] as! String
                                let photoUrl = dict["photoUrl"] as! String
                                
                                self.list.append(ListItem(rowKey: rowKey, uid: aliciUid, name: name, photoUrl: photoUrl, okundu: okundu))
                                
                            }
                            self.tableView.reloadData()
                        })
                    
                }
        }
        
    }
    
    
    class ListItem{
        var rowKey:String?
        var uid:String?
        var name:String?
        var photoUrl:String?
        var okundu:String?
        
        init(rowKey:String, uid:String, name:String, photoUrl:String, okundu:String) {
            self.rowKey = rowKey
            self.uid = uid
            self.name = name
            self.photoUrl = photoUrl
            self.okundu = okundu
        }
        
    }
}

