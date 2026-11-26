//
//  ImpactAnalyzer.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

final class ImpactAnalyzer {
    
    private let impactThreshold: Double
    private let rotationThreshold: Double
    
    init(impactThreshold: Double = 2.8, rotationThreshold: Double = 5.0) {
        self.impactThreshold = impactThreshold
        self.rotationThreshold = rotationThreshold
    }
    
    func analyze(sample: MotionSample) -> Bool {
        sample.acceleration.magnitude >= impactThreshold && sample.rotationRate.magnitude > rotationThreshold
    }
}
