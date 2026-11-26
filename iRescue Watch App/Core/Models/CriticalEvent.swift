//
//  CriticalEvent.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

nonisolated enum CriticalEventType: Equatable, Sendable {
    case verticalFall
    case rollingDescent
    case lateralImpact
    case unknown
}

nonisolated struct CriticalEvent: Equatable, Sendable {
    let type: CriticalEventType
    let severityScore: Double
    let timestamp: Date
}
