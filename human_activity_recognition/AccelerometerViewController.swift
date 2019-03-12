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


class AccelerometerViewController: UIViewController, MotionGraphContainer  {
    // import the coreml model! so convenient!!!
    let model = coreml_model()
    
    // here the acceleration values for x,y,z are displayed
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var predictionLabel: UILabel!
    
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
                    if counter%1000 == 0{
                        let remaining = 10-Int(counter/1000)
                        self.predictionLabel.text = "\(remaining)s"
                    }
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
        var flattened_result = Array(result.joined())
        flattened_result = Array(flattened_result.prefix(upTo: 1500))
        let mlMultiArrayInput = try? MLMultiArray(shape:[1500], dataType:MLMultiArrayDataType.double)
        
        for (i,elem) in flattened_result.enumerated() {
            mlMultiArrayInput![i] = NSNumber(value: elem)
        }
        
         let prediction = try! model.prediction(input: coreml_modelInput(sensor_data: mlMultiArrayInput!))
        
        let prediction_output = prediction.output
        
        let predictedJoggingScore = prediction_output["jogging"]!
        let predictedWalkingScore = prediction_output["walking"]!
        
        if predictedWalkingScore > predictedJoggingScore{
            self.predictionLabel.text = String(format: "You were walking: %.2f%", predictedWalkingScore*100)
        }
        else{
            self.predictionLabel.text = String(format: "You were running: %.2f%", predictedJoggingScore*100)
        }
        
        
        
    }
    
    func stopUpdates() {
        print("stopped accelerometer updates!")
        self.manager.stopAccelerometerUpdates()
    }
}
