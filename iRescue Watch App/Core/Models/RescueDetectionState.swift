//
//  RescueDetectionState.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 9/20/26.
//

import Foundation

nonisolated enum RescueDetectionState: Equatable, Sendable {
    case idle
    case monitoring
    case impactSuspected(ImpactSnapshot)
    case validatingInactivity(EventCandidate)
    case awaitingUserResponse(EventCandidate, responseDeadline: Date)
    case confirmedEmergency(CriticalEvent)
    case cancelled
}

nonisolated struct ImpactSnapshot: Equatable, Sendable {
    let timestamp: Date
    let accelerationMagnitude: Double
    let rotationMagnitude: Double
    let sample: MotionSample
}

nonisolated struct EventCandidate: Equatable, Sendable {
    let impact: ImpactSnapshot
    let eventType: CriticalEventType
    let severityScore: Double
    let inactivityDuration: TimeInterval
}
