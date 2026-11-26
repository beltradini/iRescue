//
//  MotionSample.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

nonisolated struct MotionVector: Equatable, Sendable {
    let x: Double
    let y: Double
    let z: Double

    var magnitude: Double {
        sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
}

nonisolated struct AttitudeSample: Equatable, Sendable {
    let pitch: Double
    let roll: Double
    let yaw: Double
}

nonisolated struct MotionSample: Equatable, Sendable {
    let timestamp: Date
    let acceleration: MotionVector
    let rotationRate: MotionVector
    let attitude: AttitudeSample
}
