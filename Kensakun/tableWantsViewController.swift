//
//  FriendsViewController.swift
//  Nimoji
//
//  Created by Kohei Masumi on 2018/07/24.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

var selectedWant = String()
var selectedDic = [String:AnyObject]()
var selectedUser = String()

let wantsPath = "wants"

class tableWantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    
    //var isObserving = false
    let sc = UIScrollView();
    var wantArray = [Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let skyblue = UIColor.rgb(r:5,g:195,b:249, alpha: 1)
        backButton.backgroundColor = skyblue
        sc.frame = self.view.frame;
        sc.delegate = self;
        sc.contentSize = CGSize(width: 375 ,height: 1000)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if Auth.auth().currentUser != nil {
            let postsRef = Database.database().reference().child(wantsPath)
            postsRef
                .queryOrdered(byChild: "want").queryEqual(toValue: WNT as String) // キーでソート
                .observe(.childAdded, with: { snapshot in
                if let _ = Auth.auth().currentUser?.uid {
                    let dictionary = snapshot.value as! [String: AnyObject]
                    self.wantArray.insert(dictionary, at: 0)
                    self.tableView.reloadData()
                }
            })
        }
        //Database.database().reference().child("users").observe(.value, with: { (snapshot) in
            
            //if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //self.searchDetail.removeAll()
                
              //  for data in snapshot {
                    
                //    if let postDict = data.value as? Dictionary<String, AnyObject> {
                        
                  //      let key = data.key
                        
                    //    let post = Search(userKey: key, postData: postDict)
                        
                        //self.searchDetail.append(post)
                   // }
                //}
            //}
            
            //self.tableView.reloadData()
        //})
       
    //}
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      //  if let destionViewController = segue.destination as? MessageVC {
            
            //destionViewController.recipient = recipient
            
            //destionViewController.messageId = messageId
        //}
    }
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //private func configureTableView() {
      //  tableView.dataSource = self
    //}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wantArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let skyblue = UIColor.rgb(r:5,g:195,b:249, alpha: 1)
        
        let cell = tableView.dequeueReusableCell (
            withIdentifier: "Cell",
            for: indexPath as IndexPath)
        let dic = wantArray[indexPath.row] as! [String: AnyObject]
        //print("投稿リスト:",dic)
        
        cell.contentView.backgroundColor = skyblue
        
        cell.textLabel?.text = dic["want"] as? String
        
        let time = dic["time"] as? String
        
        cell.detailTextLabel?.text = (dic["username"] as? String)! + " : " + (time ?? "")
        
        let userphotoURL = dic["userPhoto"] as! String
        let storage = Storage.storage()
        _ = storage.reference()
        let storef = storage.reference(forURL: userphotoURL)
        storef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                
                //DispatchQue以下略はError: UIImageView.image must be used from main thread onlyを解消する
                DispatchQueue.main.async{
                    cell.imageView?.image = UIImage(data: data!)
                }
                self.tableView.reloadData()
                
            }
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedDic = wantArray[indexPath.row] as! [String: AnyObject]
        selectedWant = (selectedDic["want"] as? String)!
        selectedUser = (selectedDic["userid"] as? String)!
                
        print("セレクトうぉんと",selectedWant)
        //部品のアラートを作る
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        //ちなみにUIAlertControllerStyle.alertをactionsheetに変えると下からにょきっと出てくるやつになるよ
        
        //OKボタン追加
        let toDetailAction = UIAlertAction(title: "詳細に移動", style: UIAlertActionStyle.default, handler:{(action: UIAlertAction!) in
            
            //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 0.3秒後に実行したい処理
                self.performSegue(withIdentifier: "toDetailOfWantViewController", sender: nil)
            }
        })
        let toProfileAction = UIAlertAction(title: "チャットに移動", style: UIAlertActionStyle.default, handler:{(action: UIAlertAction!) in
            
            //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 0.3秒後に実行したい処理
                self.performSegue(withIdentifier: "toMessage", sender: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler:{(action: UIAlertAction!) in
        
        })

            
        
        alertController.addAction(toDetailAction)
        alertController.addAction(toProfileAction)
        alertController.addAction(cancelAction)
        //アラートを表示する
        present(alertController, animated: true, completion: nil)
        
        
        //performSegue(withIdentifier: "toDetailOfWantViewController", sender: self)
    
    }
    
    // Segue 準備
    //override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
      //  if (segue.identifier == "toDetailOfWantViewController") {
        //    let DetVC: detailOfWantViewController = (segue.destination as? detailOfWantViewController)!
            // SubViewController のselectedImgに選択された画像を設定する
            //DetVC.detailWantLabel.text = selectedWant
            //let valueOfLabel = DetVC.detailWantLabel.text
            
            //print("セレクトウォント",selectedWant)
            //print("ラベルに",valueOfLabel!)
        //}
    //}
   
    
    // tap gesture
    //@IBAction func tapScreen(sender: UITapGestureRecognizer) {
      //  self.view.endEditing(true)
        //if self.view.frame.origin.y != 0{
          //  self.view.frame.origin.y = 0
        //}
    //}
    
}


