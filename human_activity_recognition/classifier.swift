//
//  classifier.swift
//  human_activity_recognition
//
//  Created by Mario Zusag   on 12.03.19.
//  Copyright © 2019 Mario Zusag  . All rights reserved.
//
// adapted from: https://github.com/ni79ls/har-keras-coreml/blob/master/HARClassifier.swift

import Foundation
import CoreML
@available(macOS 10.13, iOS 11.0, *)
public class ActivityClassifierInput: MLFeatureProvider{
    
    public var acceleration: MLMultiArray
    
    public init(acceleration: MLMultiArray) {
        self.acceleration = acceleration
    }
    
    public var featureNames: Set<String>{
        get {
            return ["acceleration"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "acceleration") {
            return MLFeatureValue(multiArray: acceleration)
        }
        return nil
    }
}


/// Model Prediction Output Type
@available(macOS 10.13, iOS 11.0, *)
public class ActivityClassifierOutput : MLFeatureProvider {
    
    /// Probability of each activity as dictionary of strings to doubles
    public let output: [String : Double]
    
    /// Labels of activity as string value
    public let classLabel: String
    
    public var featureNames: Set<String> {
        get {
            return ["output", "classLabel"]
        }
    }
    
    public func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "output") {
            return try! MLFeatureValue(dictionary: output as [NSObject : NSNumber])
        }
        if (featureName == "classLabel") {
            return MLFeatureValue(string: classLabel)
        }
        return nil
    }
    
    init(output: [String : Double], classLabel: String) {
        self.output = output
        self.classLabel = classLabel
    }
}

/// Class for model loading and prediction
@available(macOS 10.13, iOS 11.0, *)
public class ActivityClassifier {
    var model: MLModel
    
    /**
     Construct a model with explicit path to mlmodel file
     - parameters:
     - url: the file url of the model
     - throws: an NSError object that describes the problem
     */
    public init(contentsOf url: URL) throws {
        self.model = try MLModel(contentsOf: url)
    }
    
    /// Construct a model that automatically loads the model from the app's bundle
    public convenience init() {
        let bundle = Bundle(for: ActivityClassifierInput.self)
        let assetPath = bundle.url(forResource: "HARClassifier", withExtension:"mlmodelc")
        try! self.init(contentsOf: assetPath!)
    }
    
    public func prediction(input: ActivityClassifierInput) throws -> ActivityClassifierOutput {
        let outFeatures = try model.prediction(from: input)
        let result = ActivityClassifierOutput(output: outFeatures.featureValue(for: "output")!.dictionaryValue as! [String : Double], classLabel: outFeatures.featureValue(for: "classLabel")!.stringValue)
        return result
    }
    
    public func prediction(acceleration: MLMultiArray) throws -> ActivityClassifierOutput {
        let input_ = ActivityClassifierInput(acceleration: acceleration)
        return try self.prediction(input: input_)
    }
}
