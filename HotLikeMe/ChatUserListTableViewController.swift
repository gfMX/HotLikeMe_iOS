//
//  ChatUserListTableViewController.swift
//  HotLikeMe
//
//  Created by developer on 07/12/16.
//  Copyright © 2016 MezcalDev. All rights reserved.
//

import UIKit
import Firebase

class ChatUserListTableViewController: UITableViewController {

    var ref:FIRDatabaseReference!
    var ref1:FIRDatabaseReference!
    var user:FIRUser!
    
    var listUsers = [String]()
    var listChats = [String]()
    var users = [Users]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        ref1 = FIRDatabase.database().reference()
        user = FIRAuth.auth()?.currentUser

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getActiveChats()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "userCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatUserCellTableViewCell

        // Configure the cell...
        cell.chat_userName.text = users[indexPath.item].name
        cell.chat_lastMessage.text = users[indexPath.item].message
        Helper.loadImageFromUrl(url: users[indexPath.item].photo, view: cell.chat_userImage)
        cell.chat_userImage.layer.masksToBounds = false
        cell.chat_userImage.clipsToBounds = true
        cell.chat_userImage.layer.borderColor = UIColor.lightGray.cgColor
        cell.chat_userImage.layer.borderWidth = 4
        cell.chat_userImage.layer.cornerRadius = cell.chat_userImage.frame.height/1.8
        cell.chat_userImage.contentMode = UIViewContentMode.scaleAspectFill

        return cell
    }
 
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    func getActiveChats(){
        ref.child("users").child(user.uid).child("my_chats").observe(FIRDataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //print("👥 on My Chats: \(value?.allKeys)")
            self.listUsers = value?.allKeys as! [String]
            self.listChats = value?.allValues as! [String]
            print("👥 list: \(self.listUsers)")
            print("💬 list: \(self.listChats)")
            if self.users.count != self.listUsers.count{
                self.getUserChatDetails()
                print("Getting 👥 List")
            } else {
                print("List OK")
            }
        })
    }
    
    func getUserChatDetails(){
        users.removeAll()
        
        for i in 0 ..< listUsers.count {
        
            self.ref1.child("users").child(self.listUsers[i]).child("preferences").observeSingleEvent(of: .value, with: {(snapshot) in
                let value2 = snapshot.value as? NSDictionary
                
                let user_name = value2?.value(forKey: "alias") as! String
                let user_pic = value2?.value(forKey: "profile_pic_storage") as! String
                
                print ("Storage Pic: \(user_pic)")
                
                self.ref.child("chats_resume").child(self.listChats[i]).observeSingleEvent(of: .value, with: {(snapshot) in
                    let value = snapshot.value as? NSDictionary
                    
                    let user_message = value?.value(forKey: "text") as! String
                    var user_picUrl: String!
                    
                    FireConnection.storageReference.child(self.listUsers[i]).child("/images/image_" + user_pic + ".jpg").downloadURL { (URL, error) -> Void in
                        if (error != nil) {
                            print ("An error ocurred!")
                        } else {
                            user_picUrl = URL?.absoluteString
                        }
                        
                        let user = Users(name: user_name, photo: user_picUrl, message: user_message)!
                        self.users.append(user)
                        
                        if i == self.listUsers.count - 1 {
                            self.tableView.reloadData()
                        }
                        
                    }
                })
            })
            
            
        }
        
    }

}