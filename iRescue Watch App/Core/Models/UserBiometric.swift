//
//  UserBiometric.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/25/26.
//

import Foundation

nonisolated struct UserBiometricBaseline: Equatable, Sendable {
    let restingHeartRate: Double
    let averageHRV: Double
}
