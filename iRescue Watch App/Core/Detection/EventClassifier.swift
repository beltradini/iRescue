//
//  EventClassifier.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

final class EventClassifier {
    
    func classify(sample: MotionSample) -> CriticalEvent? {
        
        let verticalImpact = abs(sample.acceleration.z) > 2.5
        let lateralImpact = abs(sample.acceleration.x) > 2.5 || abs(sample.acceleration.y) > 2.5
        
        if verticalImpact {
            return CriticalEvent(
                type: .verticalFall, severityScore: 0.8, timestamp: sample.timestamp
            )
        }
        
        if lateralImpact {
            return CriticalEvent(
                type: .lateralImpact, severityScore: 0.7, timestamp: sample.timestamp
            )
        }
        
        return nil
    }
}
