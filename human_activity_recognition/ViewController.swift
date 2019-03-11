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
    let hertz: Int = 50  // 50Hz
    let manager = CMMotionManager()
    var timer: Timer!
    
    @IBOutlet weak var runningAppLogo: UIImageView!
    
    @IBOutlet weak var tenSecondsButtonClick: UIButton!
    @IBAction func tenSecondsButtonClick(_ sender: Any) {
        print("clicked")
        self.tenSecondsButtonClick.setTitle("Recording", for:.normal)
        if manager.isAccelerometerAvailable{
            get_accelerometer_data(1000)
        }
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
    
    func get_accelerometer_data(_ milliseconds: Int){
        print("Getting accelerometer data for \(milliseconds)ms ... ")
        var data = [[Double]]()
        // after that call, the accelerometer data is available
        manager.startAccelerometerUpdates()
        let unitOfMeasurement = 1000/hertz
        var counter = 0
        var singleData = [Double]()
        timer = Timer(fire: Date(),
                      interval: 1.0/Double(hertz), //frequency
                      repeats: true,
                      block: {
                        (timer) in
                        // Get the accelerometer data.
                        if let measurements = self.manager.accelerometerData{
                            let x = measurements.acceleration.x
                            let y = measurements.acceleration.y
                            let z = measurements.acceleration.z
                            
                            singleData = [Double(counter), x, y, z]
                            
                            data.append(singleData)
                            
                            if counter >= milliseconds{
                                self.save_results(data)
                                timer.invalidate()
                            }
                            counter += unitOfMeasurement
                        }
                        
                    }
        )
        // Add the timer to the current run loop.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    func save_results(_ result:[[Double]]){
        var csvString: String = "timestamp(ms),acceleration.x, acceleration.y, acceleration.z"
        for res in result{
            csvString += "\(res[0]), \(res[1]), \(res[2]), \(res[3])\n"
        }
        //print(csvString)
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            print("path:\(path)")
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
        
        
    }
    
    
        
    }

