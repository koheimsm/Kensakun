//
//  MessageViewController.swift
//  Kensakun
//
//  Created by Kohei Masumi on 2018/07/29.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

let MessagePath = "messages"
var autoid = String()

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var formWrapperView: UIView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
    var isObserving = false
    let sc = UIScrollView();
    var messageArray = [Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sc.frame = self.view.frame;
        sc.backgroundColor = UIColor.yellow;
        sc.delegate = self;
        sc.contentSize = CGSize(width: 375, height: 1000)
        
        formWrapperView.layer.borderWidth = 1
        formWrapperView.layer.borderColor = UIColor.black.cgColor
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        //let cellSet = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //cellSet!.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
        let currentUser = Auth.auth().currentUser
        if currentUser != nil {
            
            let roomRef = Database.database().reference().child("rooms").child("roomId").childByAutoId()
            autoid = roomRef.key //autoIDのID
            let room = ["user": [(currentUser!.uid) as String, selectedUser]]
            roomRef.setValue(room)
            roomRef.observe(.value, with: { (snapshot) in
                if snapshot.hasChild(MessagePath){
                    let dictionary = snapshot.value as! [String: AnyObject]
                    self.messageArray.insert(dictionary, at: 0)
                    self.tableView.reloadData()
                }else{
                    return
                }
            })
        }
        

        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageViewController.keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                print("キーボードヘイト",keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    @objc func keyboardDidHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            print("Did KeyBoard")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell (
            withIdentifier: "Cell",
            for: indexPath as IndexPath)
        let dictionary = messageArray[indexPath.row] as! [String: AnyObject]
        
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.textLabel?.text = dictionary["message"] as? String
        
        let time = dictionary["time"] as? String
        let username = dictionary["username"] as? String
        
        cell.detailTextLabel?.text = (time ?? "") + " : " + (username ?? "")
        cell.imageView?.image = permanentImage
        
        
        return cell
    }
    
    // tap gesture
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func pushGoButton(_ sender: Any) {
        if let currentUser = Auth.auth().currentUser {
            
            if let message = messageTextField.text {
                // 20文字縛り
                if 20 < message.count {
                    print("Oops!")
                    return
                }
                
                let now = Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone.current
                formatter.dateFormat = "yyyy/MM/dd HH:mm"
                let dateString = formatter.string(from: now)
                
                let roomRef = Database.database().reference().child("rooms").child("roomId").child("\(autoid)/")
                
                        let MessageRef = roomRef.child(MessagePath)
                        let data = [
                            "message": message,
                            "time": dateString,
                            "username": currentUser.displayName]
                        
                        MessageRef.childByAutoId().setValue(data)
                        print("Success!")
                
                        MessageRef.observe(.childAdded, with: { snapshot in
                            if let _ =  Auth.auth().currentUser?.uid {
                                let dictionary = snapshot.value as! [String: AnyObject]
                                self.messageArray.insert(dictionary, at: 0)
                                self.tableView.reloadData()
                            }
                        })

            }
            
        }
    }

}

