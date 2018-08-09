//
//  detailOfWantViewController.swift
//  Kensakun
//
//  Created by Kohei Masumi on 2018/07/29.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth


class detailOfWantViewController: UIViewController{
    
    @IBOutlet weak var detailWantLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailWantLabel.text = selectedWant
    }
    
}
