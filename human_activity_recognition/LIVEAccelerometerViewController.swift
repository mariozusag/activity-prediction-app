/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller to display output from the accelerometer.
 */

import UIKit
import CoreMotion
import simd
import CoreML


class LiveAccelerometerViewController: UIViewController, MotionGraphContainer  {
    // import the coreml model! so convenient!!!
    let model = live_coreml_model()
    /*
     mean values from training set:
     {'acc.x': -0.003910640484405802,
     'acc.y': 0.04424379658212213,
     'acc.z': 0.039271765727086426}
     */
    /*
     std values from training set:
     {'acc.x': 0.3282088621907262,
     'acc.y': 0.5275661316963115,
     'acc.z': 0.3762119450049213}
     */
    let x_mean = -0.0062030975433088765
    let y_mean = 0.058100063882162246
    let z_mean = 0.051295166045208625
    
    let x_std = 0.37626828873183993
    let y_std = 0.604159095921093
    let z_std = 0.43059768003197724
    
    // here the acceleration values for x,y,z are displayed
    

    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var predictionLabel: UILabel!
    
    @IBOutlet weak var goBackButtonClick: UIButton!
    
    let hertz: Int = 50  // 50Hz
    let milliseconds: Int = 1000
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
                    let x = (measurements.acceleration.x - self.x_mean)/self.x_std  // normalize like in training
                    let y = (measurements.acceleration.y - self.y_mean)/self.y_std
                    let z = (measurements.acceleration.z - self.z_mean)/self.z_std
                    
                    let acceleration: double3 = [x,y,z]
                    
                    self.graphView.add(acceleration)
                    self.setValueLabels(xyz: acceleration)
                    
                    singleData = [x, y, z]
                    
                    data.append(singleData)
                    if counter > 0{
                        if counter%1000 == 0{
                            self.predict(data)
                            data = [[Double]]()
                        }
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
        // take in 1s of accelerometer data (50 datapoints*3 acceleration axes = 150) and feed it to the trained network
        var flattened_result = Array(result.joined())
        flattened_result = Array(flattened_result.prefix(upTo: 150)) //flattened for MLMultiArray
        let mlMultiArrayInput = try? MLMultiArray(shape:[150], dataType:MLMultiArrayDataType.double)
        
        for (i,elem) in flattened_result.enumerated() {
            mlMultiArrayInput![i] = NSNumber(value: elem)
        }
       
        let prediction = try! model.prediction(input: live_coreml_modelInput(sensor_data: mlMultiArrayInput!))
        let prediction_output = prediction.output
        print(prediction_output)
        self.predictionLabel.text = "You are \(prediction.classLabel)!"
        
        
    }
    
    func stopUpdates() {
        print("stopped accelerometer updates!")
        self.manager.stopAccelerometerUpdates()
    }
}
