//
//  ViewController.swift
//  Kensakun
//
//  Created by Kohei Masumi on 2018/07/23.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import CoreLocation
import SwiftKeychainWrapper

var WNT = String()
var permanentImage: UIImage? = nil
var picurl: String!
var picurlforwant: String!


class PostViewController: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    var wantArray = [Any]()
    var buttonHelper: ButtonValidationHelper!
    var profileViewTopConstraint: NSLayoutConstraint!
    var wantViewTopConstraint: NSLayoutConstraint!
    var isprofileViewVisible = true
    var iswantViewVisible = true
    var profilePictureChanged = false
    
    var myLocationManager: CLLocationManager!
    var latitudeTaken: CLLocationDegrees!
    var longitudeTaken: CLLocationDegrees!
    
    //var downloadURL: URL!
    //var downloadString: String!
    
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var wantField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var wantView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePictureView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.notDetermined) {
            print("didChangeAuthorizationStatus:", status);
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestWhenInUseAuthorization()
        }
        // 位置情報の取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest

        //self.setRegion()
        self.imagePicker.delegate = self
    
        showLoading(state: false)
        self.wantViewCustomization()
        self.profileViewCustomization()

        if permanentImage == nil {
            getProfilePicFromStorage()
        }else{
            self.profilePictureView.image = permanentImage
        }
        wantField.delegate = self
        buttonHelper = ButtonValidationHelper(textFields: [wantField], buttons: [sendButton])
        
        // テキストを全消去するボタンを表示
        wantField.clearButtonMode = .always
        
        if Auth.auth().currentUser != nil {
            let postsRef = Database.database().reference().child("wants")
            postsRef.observe(.childAdded, with: { snapshot in
                if let _ = Auth.auth().currentUser?.uid {
                    let dictionary = snapshot.value as! [String: AnyObject]
                    self.wantArray.insert(dictionary, at: 0)
                }
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
        if profileViewTopConstraint.constant != 60 {
            self.iswantViewVisible = true
            self.isprofileViewVisible = false
            self.wantViewTopConstraint.constant = 60
            self.profileViewTopConstraint.constant = 1000
        }else{
            self.iswantViewVisible = false
            self.isprofileViewVisible = true
            self.wantViewTopConstraint.constant = 1000
            self.profileViewTopConstraint.constant = 60
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    func wantViewCustomization()  {
        
        //wantView customization
        let skyblue = UIColor.rgb(r:5,g:195,b:249, alpha: 1)
        self.wantView.backgroundColor = skyblue
        self.view.insertSubview(self.wantView, belowSubview: self.cloudsView)
        self.wantView.translatesAutoresizingMaskIntoConstraints = false
        self.wantView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.wantViewTopConstraint = NSLayoutConstraint.init(item: self.wantView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60)
        self.wantViewTopConstraint.isActive = true
        self.wantView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.wantView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0).isActive = true
        self.wantView.layer.cornerRadius = 8
        //RegisterView Customization
        
    }
    func profileViewCustomization(){
        self.view.insertSubview(self.profileView, belowSubview: self.cloudsView)
        self.profilePictureView.layer.borderColor = GlobalVariables.blue.cgColor
        self.profilePictureView.layer.borderWidth = 2
        self.profileView.translatesAutoresizingMaskIntoConstraints = false
        self.profileView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //self.profileView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.profileViewTopConstraint = NSLayoutConstraint.init(item: self.profileView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.profileViewTopConstraint.isActive = true
        self.profileView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.profileView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.profileView.layer.cornerRadius = 8
    
        if let currentUser = Auth.auth().currentUser {
            //nameLabel.text = currentUser.displayName
            nameLabel.text = currentUser.displayName
            mailLabel.text = currentUser.email
        }
    }
    func getProfilePicFromStorage(){
        let ref = Database.database().reference().child("users")
            ref.child(Auth.auth().currentUser!.uid).observeSingleEvent(of:.value, with: { (snapshot) in
                
                if  snapshot.hasChild("userPhoto"){
                    print("要素あり")
                    let value = snapshot.value as? NSDictionary
                    let imageUrl = value!["userPhoto"] as! String
                    picurlforwant = imageUrl
                    let storage = Storage.storage()
                    _ = storage.reference()
                    let storef = storage.reference(forURL: imageUrl)
                    storef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if error != nil {
                        // Uh-oh, an error occurred!
                    } else {
                        
                        permanentImage = UIImage(data:data!)
                        self.profilePictureView.image = permanentImage
                        
                        self.reloadInputViews()
                        }
                    }
                }else{
                    print("要素なし")
                    permanentImage = UIImage(named: "default profile")
                    self.profilePictureView.image = permanentImage
                    self.setUserPhotoToStorage(pic: permanentImage!, quarity: 1.0)
                    
                }
            })
    }
    func setUserPhotoToStorage(pic: UIImage, quarity: CGFloat ){
        var data = NSData()
        data = UIImageJPEGRepresentation(pic, quarity)! as NSData
        // set upload path
        let user = Auth.auth().currentUser!
        //let userPath = "\(user.uid)/"
        //let filePath = "userPhoto"
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let storageRef = Storage.storage().reference(forURL:"gs://kensakun-30cb0.appspot.com/")
        storageRef.child("\(user.uid)/").child("userPhoto").putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //store downloadURL
                let downloadURL = metaData!.downloadURL()!
                let downloadString = downloadURL.absoluteString
                //store downloadURL at database
                picurl = downloadString
                self.setNewPhotoUrl()
            }
        }
    }
    
    
    @IBAction func humburger(_ sender: Any){
        self.iswantViewVisible = false
        self.wantViewTopConstraint.constant = 1000
        self.isprofileViewVisible = true
        self.profileViewTopConstraint.constant = 60
        self.profilePictureChanged = false
        //if Auth.auth().currentUser != nil {
            //let url = URL(string: (Auth.auth().currentUser?.photoURL?.absoluteString)!)
          //  let session = URLSession.shared
            //let task = session.dataTask(with: url!) { (data, response, err) in
              //  if err != nil {
                //    return
                //}
                //DispatchQueue.main.async{
                //self.profilePictureView?.image = UIImage(data: data!)
                //}
            //}
            //task.resume()
            
        //}

        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.closeProfile)))
    }
    //@objc func closeProfile() {
      //  self.profileViewTopConstraint.constant = 1000
    //}
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if (status == .authorized || status == .notDetermined) {
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    @IBAction func selectPic(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        //self.profilePictureView.image = pickedImage
        
        picker.dismiss(animated: true, completion: nil)
        self.iswantViewVisible = false
        self.isprofileViewVisible = true
        self.wantViewTopConstraint.constant = 1000
        self.profileViewTopConstraint.constant = 60
        
        if pickedImage != nil{
            self.setUserPhotoToStorage(pic: pickedImage!, quarity: 0.8)
            
            //let when = DispatchTime.now() + 3
            //DispatchQueue.main.asyncAfter(deadline: when) {
            
                self.profilePictureChanged = true
                permanentImage = pickedImage
                self.profilePictureView.image = permanentImage
                
            //}
        }else{
            self.profilePictureChanged = false
        }
    }
    func setNewPhotoUrl(){
        let dataforUsers = ["userPhoto": picurl] as [String : Any]
        let ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser!
        ref.child("users").child(currentUser.uid).updateChildValues(dataforUsers)
        
        let photoUrl = URL(string:picurl)
        let changeRequest = currentUser.createProfileChangeRequest()
        changeRequest.photoURL = photoUrl
        changeRequest.commitChanges { error in
            if let error = error {
                print(error)
                print("error")
                
                return
            }
        }
    }
    
    @IBAction func closeViewByButton(_ sender: Any) {
        self.isprofileViewVisible = false
        self.profileViewTopConstraint.constant = 1000
        self.profilePictureChanged = false
        self.iswantViewVisible = true
        self.wantViewTopConstraint.constant = 60
        
    }
    //UITextFieldが編集された直前に呼ばれる
    func textFieldDidBeginEditing(_ textField: UITextField) {
        buttonHelper = ButtonValidationHelper(textFields: [wantField], buttons: [sendButton])
        print("textFieldDidBeginEditing: \(textField.text!)")
    }
    
    //UITextFieldが編集された直後に呼ばれる
    func textFieldDidEndEditing(_ textField: UITextField) {
        buttonHelper = ButtonValidationHelper(textFields: [wantField], buttons: [sendButton])
        print("textFieldDidEndEditing: \(textField.text!)")
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    
    
    @IBAction func pushSendButton(_ sender: Any) {
        myLocationManager.startUpdatingLocation() // 位置情報のアップデート
        showLoading(state: true)
        if let currentUser = Auth.auth().currentUser {
            
            if  wantField.text != nil{
                let desire = wantField.text?.trimmingCharacters(in: .whitespaces).uppercased()
                WNT = desire!
                // 20文字縛り
                if 0 < (desire?.count)! && (desire?.count)! < 20 {
                    let now = Date()
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.current
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    let dateString = formatter.string(from: now)
                    
                    let when = DispatchTime.now() + 1
                    let when2 = DispatchTime.now() + 1.5
                    
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        
                        let ref = Database.database().reference()
                        if self.latitudeTaken != nil && self.longitudeTaken != nil{
                            
                            if  picurlforwant != nil{
                                let data = [
                                    "want": desire!,
                                    "time": dateString,
                                    "userid": currentUser.uid,
                                    "username": currentUser.displayName!,
                                    "latitude": self.latitudeTaken!,
                                    "longitude": self.longitudeTaken!,
                                    "userPhoto": picurlforwant
                                    ] as [String : Any]
                                ref.child("wants").childByAutoId().setValue(data)
                                
                            }else{
                                //プロフィール画像設定前で、picurlforwantがまだデータベース似ない場合、picurlforwantはImagePickerで変更前、picurlは変更後の変数(画像url)
                                let data = [
                                    "want": desire!,
                                    "time": dateString,
                                    "userid": currentUser.uid,
                                    "username": currentUser.displayName!,
                                    "latitude": self.latitudeTaken!,
                                    "longitude": self.longitudeTaken!,
                                    "userPhoto": picurl
                                    ] as [String : Any]
                                ref.child("wants").childByAutoId().setValue(data)
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: when2) {
                                self.present((self.storyboard?.instantiateViewController(withIdentifier: "table"))!,
                                             animated: true,
                                             completion: nil)
                                self.showLoading(state: false)
                                self.wantField.text = nil
                            }
                            
                        }else{
                            print("位置情報の取得ができていません")
                            return
                        }
                        print("書いたよ!")
                    }
                }else{
                    print("Oops!")
                    return
                
                
                //}else{
                  //  self.showLoading(state: false)
                    //print("まだだよ")
                    //self.wantField.text = nil
                    //return
                //}
               }
            }
        }
    }
    @IBAction func LogOut(_ sender: Any) {
        do {
            //do-try-catchの中で、FIRAuth.auth()?.signOut()を呼ぶだけで、ログアウトが完了
            try Auth.auth().signOut()
            KeychainWrapper.standard.removeObject(forKey: "uid")
            //先頭のtopに遷移
            let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "opening")
            self.present(storyboard, animated: true, completion: nil)
        }catch let error as NSError {
            print("\(error.localizedDescription)")
        }
        //グローバル変数の初期化
        WNT = ""
        permanentImage = nil
        picurl = nil
        picurlforwant = nil
    }
    
    
    // 位置情報が更新されるたびに呼ばれる
    //func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      //  guard let newLocation = locations.last else {
        //    return
        //}
        //self.latitudeTaken = newLocation.coordinate.latitude
        //print("緯度:",latitudeTaken!)
        //self.longitudeTaken = newLocation.coordinate.longitude
        //manager.stopUpdatingLocation() // 位置情報の取得停止

    //}
    //func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      //  print("位置情報の取得に失敗しました")
    //}

    // 認証が変更された時に呼び出されるメソッド.
    //private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
      //  switch status{
        //case .notDetermined:
          //  print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 起動中のみの取得許可を求める
            //myLocationManager.requestWhenInUseAuthorization()
        
            //break
        //case .denied:
          //  print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
                        //break
        //case .restricted:
          //  print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            //break
        //case .authorizedAlways:
          //  print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            //break
        //case .authorizedWhenInUse:
          //  print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            //break
        //}
    //}
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.5
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
                self.darkView.isHidden = true
            })
        }
    }
    
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }

}
extension PostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 許可を求めるコードを記述する（後述）
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
            
        }
            
        self.latitudeTaken = newLocation.coordinate.latitude
        print("緯度:",latitudeTaken!)
        self.longitudeTaken = newLocation.coordinate.longitude
        print("経度:",longitudeTaken!)
        manager.stopUpdatingLocation() // 位置情報の取得停止
    }    // requestLocation()を使用する場合、失敗した際のDelegateメソッドの実装が必須
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
}
