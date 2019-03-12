//
//  ViewController.swift
//  human_activity_recognition
//
//  Created by Mario Zusag   on 05.03.19.
//  Copyright © 2019 Mario Zusag  . All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var runningAppLogo: UIImageView!
    
    @IBOutlet weak var tenSecondsButtonClick: UIButton!
    @IBAction func tenSecondsButtonClick(_ sender: Any) {
        print("clicked")
        self.tenSecondsButtonClick.setTitle("Recording", for:.normal)
    }
    // Add constraints, such that the logo will always appear centered
    @IBOutlet weak var verticalLogoAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalLogoAlignmentConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Move the logo out of the visible screen before the view is loaded
        self.runningAppLogo.alpha = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        self.runningAppLogo.alpha = 1.0},
                       completion:nil)
        
        UIView.animate(withDuration: 0.5,
                       delay: 1.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        self.tenSecondsButtonClick.alpha = 1.0},
                       completion:nil)
        
    }
    
        
    }

