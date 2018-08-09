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
import SwiftKeychainWrapper

class AgainWelcomeViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet var emailView: UIView!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet var waringLabels: UILabel! //please try again
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loginButton:UIButton!
    //@IBOutlet var inputFields: [UITextField]!
    
    
    //@IBOutlet weak var otpField: UITextField!
    //@IBOutlet weak var otpMessageLabel: UILabel!
    
    var emailViewTopConstraint: NSLayoutConstraint!
    var isemailViewVisible = true
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }
    var buttonHelper: ButtonValidationHelper!

    
    //MARK: Methods
    func customization()  {
        
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
        
        
        
    }
    
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }

    //@IBAction func switchViews(_ sender: UIButton) {
    //  if self.isemailViewVisible {
    //    self.isemailViewVisible = false
    //  sender.setTitle("Login", for: .normal)
    //self.emailViewTopConstraint.constant = 1000
    //self.registerTopConstraint.constant = 60
    //  } else {
    //    self.isemailViewVisible = true
    //  sender.setTitle("Create New Account", for: .normal)
    //self.emailViewTopConstraint.constant = 60
    //self.registerTopConstraint.constant = 1000
    //}
    //   UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
    //     self.view.layoutIfNeeded()
    //})
    //for item in self.waringLabels {
    //  item.isHidden = true
    //}
    //}
    
    
    @IBAction func login(_ sender: Any) {
        showLoading(state: true)
        if let email = loginEmailField.text,
            let password = passwordField.text {
            if email.isEmpty {
                print("Oops!")
                loginEmailField.layer.borderColor = UIColor.red.cgColor
                return
            }
            if password.isEmpty {
                print("Oops!")
                passwordField.layer.borderColor = UIColor.red.cgColor
                return
            }
            loginEmailField.layer.borderColor = UIColor.black.cgColor
            passwordField.layer.borderColor = UIColor.black.cgColor
            
            
            // ログイン
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                if let error = error {
                    print(error)
                    print("Error!")
                    self.showLoading(state: false)
                    self.waringLabels.isHidden = false
                    return
                } else {
                    print("Success!")
                    KeychainWrapper.standard.set(Auth.auth().currentUser!.uid, forKey: "uid")
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.present((self.storyboard?.instantiateViewController(withIdentifier: "Desire"))!,
                                     animated: true,
                                     completion: nil)
                        self.showLoading(state: false)
                    }
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
    
    //@IBAction func otpAuthendication(_ sender: Any) {
    
    
    //}
    
    //MARK: Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
         waringLabels.isHidden = true
    }
    
    
    
    //func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //  textField.resignFirstResponder()
    //return true
    //}
    
    
    //MARK: Viewcontroller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.showLoading(state: false)
        buttonHelper = ButtonValidationHelper(textFields: [loginEmailField, passwordField], buttons: [loginButton])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()

        self.isemailViewVisible = true
        self.emailViewTopConstraint.constant = 60
        

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y = 0
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
}


