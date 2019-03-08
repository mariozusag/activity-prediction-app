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
    let hertz: Double = 50  // 50Hz
    let manager = CMMotionManager()
    var timer: Timer!
    
    @IBOutlet weak var runningAppLogo: UIImageView!
    
    @IBOutlet weak var tenSecondsButtonClick: UIButton!
    @IBAction func tenSecondsButtonClick(_ sender: Any) {
        print("clicked")
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            //self.tenSecondsButtonClick.alpha = 0.0
            //self.runningAppLogo.isHidden = true
        }, completion:nil)
        if manager.isAccelerometerAvailable{
            get_accelerometer_data(10000)
        }
    }
    // Add constraints, such that the logo will always appear centered
    @IBOutlet weak var verticalLogoAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var horizontalLogoAlignmentConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Move the logo out of the visible screen before the view is loaded
        horizontalLogoAlignmentConstraint.constant -= view.bounds.width
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // EaseIn the logo into the screen after the view appeared
        UIView.animate(withDuration: 1.5,
                       delay: 0.0,
                       options: [.curveEaseOut],
                       animations:{
                        self.horizontalLogoAlignmentConstraint.constant += self.view.bounds.width
                         self.view.layoutIfNeeded()
                       },
                       completion: nil)
        // move the logo to the top
        UIView.animate(withDuration: 1.5,
                       delay: 1.5,
                       options: [.curveEaseOut],
                       animations:{
                        self.verticalLogoAlignmentConstraint.constant -= 0.25*self.view.bounds.height
                        self.view.layoutIfNeeded()},
                       completion: nil)
        
    }
    
    func get_accelerometer_data(_ milliseconds: Double){
        print("Inside get accelerometer data")
        
        // after that call, the accelerometer data is available
        manager.startAccelerometerUpdates()
        var counter = hertz*milliseconds/1000.0
        timer = Timer(fire: Date(),
                      interval: 1.0/hertz, //frequency
                      repeats: true,
                      block: {
                        (timer) in
                        // Get the accelerometer data.
                        if let data = self.manager.accelerometerData{
                            let x = data.acceleration.x
                            let y = data.acceleration.y
                            let z = data.acceleration.z
                            print("x: \(x), y: \(y), \(z)")
                            if counter <= 0{
                                timer.invalidate()
                            }
                            counter -= 1
                            
                        }
        })
        // Add the timer to the current run loop.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
        }
    
    func show_countdown(){
        
    }
    
        
    }

