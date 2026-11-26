//
//  SeverityLevel.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/25/26.
//

import Foundation

nonisolated enum SeverityLevel {
    case low
    case moderate
    case critical
}

func severityLevel(from score: Double) -> SeverityLevel {
    switch score {
    case 0.0..<0.4:
        return .low
    case 0.4..<0.75:
        return .moderate
    default:
        return .critical
    }
}
