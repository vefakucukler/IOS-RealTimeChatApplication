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

class TalkViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "talkTableViewCell") as! TalkTableViewCell
        
        let info = self.list[indexPath.row]
        
        if self.auth.currentUser!.uid == info.gonderenUid{
            cell.messageTip(isInComing: false)
        }else{
            cell.messageTip(isInComing: true)
        }
        
        cell.label.text = info.mesaj
        
        return cell
    }
    
    @IBAction func kapat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mesajGonder(_ sender: Any) {
        self.mesajGonder()
    }
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var viewSendBottomConst: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textMesaj: UITextField!
    
    
    var list = [ListItem]()
    var dataBaseRef:DatabaseReference!
    var auth:Auth!
    var aliciName = ""
    var aliciUid = ""
    
    var chatInboxInfo:NSDictionary!
    var chatLastInfo:NSDictionary!
    var rowKeyChatInbox = ""
    var rowKeyChatLast = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataBaseRef = Database.database().reference()
        auth = Auth.auth()
        
        navBar.topItem?.title = self.aliciName + " ile Sohbet"
        self.tableView.register(TalkTableViewCell.self, forCellReuseIdentifier: "talkTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        self.createChat()
    }
    
    func tableViewScrollToBottom(animated:Bool){
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (true) in
            if self.list.count > 0{
                self.tableView.scrollToRow(at: IndexPath(row: (self.list.count - 1), section: 0), at: .bottom, animated: animated)
            }
        }
    }
    
    func mesajGonder(){
        let inboxKey = self.chatInboxInfo["inboxKey"] as! String
        let gonderenUid = self.auth.currentUser!.uid
        let mesaj = self.textMesaj.text
        
        let postData = ["inboxKey":inboxKey, "gonderenUid":gonderenUid, "mesaj":mesaj]
        dataBaseRef.child(Child.CHATS).childByAutoId().setValue(postData) { (error, snapshot) in
            self.textMesaj.text = ""
            self.dataBaseRef.child(Child.CHAT_LAST).child(self.rowKeyChatLast).child("mesajKey").setValue(String(snapshot.key!))
            self.dataBaseRef.child(Child.CHAT_INBOX).child(self.rowKeyChatInbox).child("okundu").setValue("1")
        }
    }
    
    
    func createChat(){
        self.dataBaseRef.child(Child.CHAT_INBOX)
            .queryOrdered(byChild:"gonderenUid")
            .queryEqual(toValue:self.auth.currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    
                    if (dict["aliciUid"] as!  String) == self.aliciUid{
                        self.chatInboxInfo = dict
                        
                        self.dataBaseRef.child(Child.CHAT_INBOX)
                            .queryOrdered(byChild:"gonderenUid")
                            .queryEqual(toValue:self.aliciUid).observeSingleEvent(of: .value, with: { (snapshot) in
                                for child in snapshot.children{
                                    let snap = child as! DataSnapshot
                                    self.rowKeyChatInbox = snap.key
                                }
                            })
                        
                        
                        self.dataBaseRef.child(Child.CHAT_LAST)
                            .queryOrdered(byChild: "inboxKey")
                            .queryEqual(toValue: (dict["inboxKey"] as! String)).observeSingleEvent(of: .value, with: { (snapshot) in
                                for child in snapshot.children{
                                    let snap = child as! DataSnapshot
                                    self.rowKeyChatLast = snap.key
                                }
                            })
                        break
                    }
                }
                
                self.createChatInboxAndChatLast()
                self.chats()
                self.chatLast()
        }
        
    }
    
    func createChatInboxAndChatLast(){
        if self.chatInboxInfo == nil{
            let key = dataBaseRef.childByAutoId().key
            
            // gönderen için
            self.chatInboxInfo = ["inboxKey":key!, "gonderenUid":self.auth.currentUser!.uid, "aliciUid":self.aliciUid, "okundu":"0"]
            dataBaseRef.child(Child.CHAT_INBOX).childByAutoId().setValue(self.chatInboxInfo)
            
            // alici için
            self.chatInboxInfo = ["inboxKey":key!, "gonderenUid":self.aliciUid, "aliciUid":self.auth.currentUser!.uid, "okundu":"0"]
            dataBaseRef.child(Child.CHAT_INBOX).childByAutoId().setValue(self.chatInboxInfo) { (error, snapshot) in
                self.rowKeyChatInbox = String(snapshot.key!)
            }
            
            // son mesaj için
            self.chatLastInfo = ["inboxKey":key!, "mesajKey":""]
            dataBaseRef.child(Child.CHAT_LAST).childByAutoId().setValue(self.chatLastInfo) { (error, snapshot) in
                self.rowKeyChatLast = String(snapshot.key!)
            }
            
        }
    }
    
    func chats(){
        dataBaseRef.child(Child.CHATS)
            .queryOrdered(byChild: "inboxKey")
            .queryEqual(toValue: (self.chatInboxInfo["inboxKey"] as! String))
            .observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! NSDictionary
                    
                    let gonderenUid = dict["gonderenUid"] as! String
                    let mesaj = dict["mesaj"] as! String
                    
                    self.list.append(ListItem(gonderenUid: gonderenUid, mesaj: mesaj))
                }
                self.tableView.reloadData()
                self.tableViewScrollToBottom(animated: true)
                
        }
        
    }
    
    func chatLast(){
        dataBaseRef.child(Child.CHAT_LAST)
            .queryOrdered(byChild: "inboxKey")
            .queryEqual(toValue: (self.chatInboxInfo["inboxKey"] as! String))
            .observe(.childChanged) { (snapshot) in
                
                if let dict = snapshot.value as? NSDictionary{
                    let mesajKey = dict["mesajKey"] as! String
                    
                    self.dataBaseRef.child(Child.CHATS)
                        .child(mesajKey)
                        .observeSingleEvent(of: .value, with: { (snapshot) in
                            if let dict = snapshot.value as? NSDictionary{
                                
                                let gonderenUid = dict["gonderenUid"] as! String
                                let mesaj = dict["mesaj"] as! String
                                
                                self.list.append(ListItem(gonderenUid: gonderenUid, mesaj: mesaj))
                            }
                            self.tableView.reloadData()
                            self.tableViewScrollToBottom(animated: false)
                        })
                    
                }
                
        }
        
    }
    
    
    @objc func keyboardWillShow(notification:Notification){
        if let userInfo = notification.userInfo{
            if let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                self.viewSendBottomConst.constant = -(keyboardSize.height - self.view.safeAreaInsets.bottom)
                self.tableViewScrollToBottom(animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification:Notification){
        self.viewSendBottomConst.constant = 0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.endEditing(true)
    }
    
    class ListItem{
        
        var gonderenUid:String?
        var mesaj:String?
        
        init(gonderenUid:String, mesaj:String) {
            self.gonderenUid = gonderenUid
            self.mesaj = mesaj
        }
        
    }
}

