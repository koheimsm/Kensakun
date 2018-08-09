//
//  top.swift
//  Kensakun
//
//  Created by Kohei Masumi on 2018/07/15.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//

import UIKit

class top:UIViewController{
    
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet weak var buttonView:UIView!
    
    var buttonViewTopConstraint: NSLayoutConstraint!
    var isbuttonViewVisible = true

    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }
    //func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        //return CGRect(x: x, y: y, width: width, height: height)
    //}
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skyblue = UIColor.rgb(r:5,g:195,b:249, alpha: 1)
        self.buttonView.backgroundColor = skyblue
        self.view.insertSubview(self.buttonView, belowSubview: self.cloudsView)
    self.buttonView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.buttonView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        //self.buttonViewTopConstraint = NSLayoutConstraint.init(item: self.buttonView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 60)
        //self.buttonViewTopConstraint.isActive = true
        self.buttonView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45).isActive = true
        self.buttonView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        self.buttonView.layer.cornerRadius = 8
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
        if self.isbuttonViewVisible {
        } else {
            self.isbuttonViewVisible = true
            self.buttonViewTopConstraint.constant = 60
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
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
