/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Defines a protocol that the view controllers conform to and provides helper methods for updating labels.
 */

import CoreMotion
import UIKit
import simd

protocol MotionGraphContainer {
    
    var valueLabels: [UILabel]! { get }
    
    func get_accelerometer_data()
    
    func stopUpdates()
}

extension MotionGraphContainer {
    private var sortedLabels: [UILabel] {
        return valueLabels.sorted { $0.center.y < $1.center.y }
    }
    
    func setValueLabels(xyz: double3) {
        let sortedLabels = self.sortedLabels
        sortedLabels[0].text = String(format: "x: %+6.4f", xyz[0])
        sortedLabels[1].text = String(format: "y: %+6.4f", xyz[1])
        sortedLabels[2].text = String(format: "z: %+6.4f", xyz[2])
    }
    
}
