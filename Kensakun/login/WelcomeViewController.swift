//
//  WelcomeViewController.swift
//  Kensakun
//
//  Created by Kohei Masumi on 2018/07/16.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SwiftKeychainWrapper


class WelcomeViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet var registerView: UIView!
    @IBOutlet var emailView: UIView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet var waringLabels: [UILabel]!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet var inputFields: [UITextField]!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    //@IBOutlet weak var otpField: UITextField!
    //@IBOutlet weak var otpMessageLabel: UILabel!
    var emailViewTopConstraint: NSLayoutConstraint!
    var registerTopConstraint: NSLayoutConstraint!
    var isemailViewVisible = true
    var downloadURL: URL!
    var downloadString: String!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    var buttonHelper: ButtonValidationHelper!

    //MARK: Methods
    func customization()  {
        self.darkView.alpha = 0
        self.profilePicView.layer.borderColor = GlobalVariables.blue.cgColor
        self.profilePicView.layer.borderWidth = 2
        //LoginView customization
        self.view.insertSubview(self.emailView, belowSubview: self.cloudsView)
        self.emailView.translatesAutoresizingMaskIntoConstraints = false
        self.emailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.emailViewTopConstraint = NSLayoutConstraint.init(item: self.emailView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60)
        self.emailViewTopConstraint.isActive = true
        self.emailView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.emailView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.emailView.layer.cornerRadius = 8
        
        //RegisterView Customization
        self.view.insertSubview(self.registerView, belowSubview: self.cloudsView)
        self.registerView.translatesAutoresizingMaskIntoConstraints = false
        self.registerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.registerTopConstraint = NSLayoutConstraint.init(item: self.registerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.registerTopConstraint.isActive = true
        self.registerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.6).isActive = true
        self.registerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.registerView.layer.cornerRadius = 8
    }
    
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func register(_ sender: Any) {
        showLoading(state: true)
        if let username = registerNameField.text,
            let email = loginEmailField.text,
            let password = passwordField.text{
            if username.isEmpty {
                print("Oops!")
                registerNameField.layer.borderColor = UIColor.red.cgColor
                return
            }
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if let error = error {
                    print(error)
                    print("error")
                    self.showLoading(state: false)
                    //self.waringLabels.isHidden = false
                    return
                }
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print(error)
                            print("error")
                            self.showLoading(state: false)
                            //self.waringLabels.isHidden = false
                            return
                        }else{
                            //let changeRequestForPic = user.createProfileChangeRequest()
                            //changeRequestForPic.photoURL = self.downloadURL
                           
                            //changeRequestForPic.commitChanges() { error in
                              //  if let error = error {
                                //    print(error)
                                  //  print("error")
                                    //self.showLoading(state: false)
                                    //self.waringLabels.isHidden = false
                                    //return
                                //}else{
                                    print("Success!")
                                    let ref = Database.database().reference().child("users").ref.child("\(user.uid)/")
                                    let dic = [
                                        "userid": (Auth.auth().currentUser?.uid)!,
                                        "username": username,
                                        "email": email,
                                        "password": password,
                                        //"userPhoto": self.downloadString
                                        
                                        ] as [String : Any]
                                    ref.setValue(dic)
                                    
                                    let when = DispatchTime.now() + 1
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                        self.present((self.storyboard?.instantiateViewController(withIdentifier: "Desire"))!,
                                         animated: true,
                                         completion: nil)
                                        self.showLoading(state: false)
                                        //self.waringLabels.isHidden = false
                                    }
                            
                        
                        }
                    }
                }else{
                    print("Error - User not found")
                    }
                }
        }
    }
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
    
    @IBAction func toRegisterView(_ sender: Any) {
    self.isemailViewVisible = false
        buttonHelper = ButtonValidationHelper(textFields: [registerNameField], buttons: [registerButton])
        self.emailViewTopConstraint.constant = 1000
        self.registerTopConstraint.constant = 60
        
    }
    
    
    
    @IBAction func pushBackButton(_ sender: Any) {
        if registerTopConstraint.constant == 60{
            self.isemailViewVisible = true
            self.emailViewTopConstraint.constant = 60
            self.registerTopConstraint.constant = 1000
        }else{
            self.present((self.storyboard?.instantiateViewController(withIdentifier: "opening"))!,
                         animated: true,
                         completion: nil)
        }
        
        
    }
    

    //MARK: Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    //func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //  textField.resignFirstResponder()
    //return true
    //}
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        showLoading(state: false)
        buttonHelper = ButtonValidationHelper(textFields: [loginEmailField, passwordField], buttons: [confirmButton])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
        if registerTopConstraint.constant != 60 {
            self.isemailViewVisible = true
            self.emailViewTopConstraint.constant = 60
            self.registerTopConstraint.constant = 1000
        }else{
            self.isemailViewVisible = false
            self.emailViewTopConstraint.constant = 1000
            self.registerTopConstraint.constant = 60
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
        for item in self.waringLabels {
            item.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            
        }
    }
    // tap gesture
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
            }
    }
}

