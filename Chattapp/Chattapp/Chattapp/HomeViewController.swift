//
//  HomeViewController.swift
//  Chattapp
//
//  Created by Vefa Küçükler on 13.05.2019.
//  Copyright © 2019 Vefa Küçükler. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "talkViewController") as! TalkViewController
        vc.aliciName = list[indexPath.row].name!
        vc.aliciUid = list[indexPath.row].uid!
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
        
        return cell
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "inboxViewController") as! InboxViewController
            self.present(vc, animated: true, completion: nil)
        }else if item.tag == 2
        {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profilViewController") as! ProfilViewController
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    var list = [ListItem]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cikis(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewController") as! ViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableLoad()

       
    }
    
    func tableLoad()
    {
        let dataBaseRef = Database.database().reference()
        dataBaseRef.child("users").observeSingleEvent(of: .value) {(snapshot) in
            for child in snapshot.children
            {
                let snap = child as! DataSnapshot
                let dict = snap.value as! NSDictionary
                
                let uid = dict["uid"] as! String
                let name = dict["name"] as! String
                let url = dict["photoUrl"] as! String
                
                if uid != Auth.auth().currentUser!.uid
                {
                    self.list.append(ListItem(uid: uid, name: name, photoUrl: url))
                }
                
                
            }
            self.tableView.reloadData()
        }
    }
    
    class ListItem
    {
        var uid:String?
        var name:String?
        var photoUrl:String?
        
        init(uid:String, name:String, photoUrl:String)
        {
            self.uid = uid
            self.name = name
            self.photoUrl = photoUrl
        }
    }
    


}
