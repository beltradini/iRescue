//
//  SeverityScoringEngine.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/25/26.
//

import Foundation

final class SeverityScoringEngine {
    
    func computeScore(
        impactMagnitude: Double,
        inactivityDuration: Double,
        currentHR: Double?,
        baseline: UserBiometricBaseline?
    ) -> Double {
        
        var score = 0.0
        let includesBiometrics = currentHR != nil && baseline != nil
        let impactWeight = includesBiometrics ? 0.4 : 0.5
        let inactivityWeight = includesBiometrics ? 0.3 : 0.5
        
        // Impact
        score += min(impactMagnitude / 5.0, 1.0) * impactWeight
        
        // Inactivity
        score += min(inactivityDuration / 15.0, 1.0) * inactivityWeight
        
        // Heart rate
        if let hr = currentHR,
           let base = baseline {
            
            let deviation = abs(hr - base.restingHeartRate)
            score += min(deviation / 40.0, 1.0) * 0.3
        }
        
        return min(score, 1.0)
    }
}
