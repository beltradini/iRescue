//
//  InactivityValidator.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

final class InactivityValidator {
    
    private let inactivityThreshold: Double
    private let rotationThreshold: Double
    private let requiredDuration: TimeInterval
    
    init(
        inactivityThreshold: Double = 0.15,
        rotationThreshold: Double = 0.1,
        requiredDuration: TimeInterval = 10
    ) {
        self.inactivityThreshold = inactivityThreshold
        self.rotationThreshold = rotationThreshold
        self.requiredDuration = requiredDuration
    }
    
    func validate(impactTime: Date, samples: [MotionSample]) -> Bool {
        let postImpactSamples = samples.filter { $0.timestamp > impactTime }
        
        guard let mostRecentSample = postImpactSamples.last else { return false }
        guard mostRecentSample.timestamp.timeIntervalSince(impactTime) >= requiredDuration else { return false }
        
        return postImpactSamples.allSatisfy { sample in
            sample.acceleration.magnitude < inactivityThreshold && sample.rotationRate.magnitude < rotationThreshold
        }
    }
}
