/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller to display output from the accelerometer.
 */

import UIKit
import CoreMotion
import simd

class AccelerometerViewController: UIViewController, MotionGraphContainer {
    
    // here the acceleration values for x,y,z are displayed
    @IBOutlet weak var graphView: GraphView!
    
    @IBAction func goBackButtonClick(_ sender: Any) {
    }
    
    @IBOutlet weak var goBackButtonClick: UIButton!
    
    
    let hertz: Int = 50  // 50Hz
    let milliseconds: Int = 10000
    let manager = CMMotionManager()
    var timer: Timer!
    
    @IBOutlet var valueLabels: [UILabel]!
    
    // MARK: UIViewController overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        get_accelerometer_data()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopUpdates()
    }
    
    
    // MARK: MotionGraphContainer implementation
    
    func get_accelerometer_data(){
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
                    
                    let acceleration: double3 = [x,y,z]
                    
                    self.graphView.add(acceleration)
                    self.setValueLabels(xyz: acceleration)
                    
                    singleData = [Double(counter), x, y, z]
                    
                    data.append(singleData)
                    
                    if counter >= self.milliseconds{
                        self.predict(data)
                        timer.invalidate()
                    }
                    
                    if self.goBackButtonClick.isTouchInside{
                        timer.invalidate()
                        self.stopUpdates()
                    }
                    
                    counter += unitOfMeasurement
               }
            }
        )
        // Add the timer to the current run loop.
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.default)
    }
    
    func predict(_ result:[[Double]]){
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
    
    func stopUpdates() {
        print("stopped accelerometer updates!")
        self.manager.stopAccelerometerUpdates()
    }
}
