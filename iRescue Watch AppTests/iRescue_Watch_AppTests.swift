//
//  iRescue_Watch_AppTests.swift
//  iRescue Watch AppTests
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation
import Testing
@testable import iRescue_Watch_App

struct iRescue_Watch_AppTests {

    @Test func impactAnalyzerDetectsCombinedImpactAndRotation() {
        let analyzer = ImpactAnalyzer()
        let sample = makeSample(
            acceleration: MotionVector(x: 3.0, y: 0.0, z: 0.0),
            rotation: MotionVector(x: 6.0, y: 0.0, z: 0.0)
        )

        #expect(analyzer.analyze(sample: sample))
    }

    @Test func impactAnalyzerRejectsImpactWithoutRotation() {
        let analyzer = ImpactAnalyzer()
        let sample = makeSample(
            acceleration: MotionVector(x: 3.0, y: 0.0, z: 0.0),
            rotation: MotionVector(x: 0.2, y: 0.0, z: 0.0)
        )

        #expect(!analyzer.analyze(sample: sample))
    }

    @Test func classifierIdentifiesVerticalFall() {
        let classifier = EventClassifier()
        let sample = makeSample(acceleration: MotionVector(x: 0.0, y: 0.0, z: -3.0))

        let event = classifier.classify(sample: sample)

        #expect(event?.type == .verticalFall)
        #expect(event?.severityScore == 0.8)
    }

    @Test func classifierIdentifiesLateralImpact() {
        let classifier = EventClassifier()
        let sample = makeSample(acceleration: MotionVector(x: 3.0, y: 0.0, z: 0.0))

        let event = classifier.classify(sample: sample)

        #expect(event?.type == .lateralImpact)
        #expect(event?.severityScore == 0.7)
    }

    @Test func inactivityValidatorRequiresFullObservationWindow() {
        let impactTime = Date()
        let validator = InactivityValidator(requiredDuration: 2.0)
        let samples = [
            makeSample(timestamp: impactTime.addingTimeInterval(0.5)),
            makeSample(timestamp: impactTime.addingTimeInterval(1.0))
        ]

        #expect(!validator.validate(impactTime: impactTime, samples: samples))
    }

    @Test func inactivityValidatorAcceptsSustainedInactivity() {
        let impactTime = Date()
        let validator = InactivityValidator(requiredDuration: 2.0)
        let samples = [
            makeSample(timestamp: impactTime.addingTimeInterval(0.5)),
            makeSample(timestamp: impactTime.addingTimeInterval(1.0)),
            makeSample(timestamp: impactTime.addingTimeInterval(2.0))
        ]

        #expect(validator.validate(impactTime: impactTime, samples: samples))
    }

    @Test func inactivityValidatorRejectsMovementAfterImpact() {
        let impactTime = Date()
        let validator = InactivityValidator(requiredDuration: 1.0)
        let samples = [
            makeSample(timestamp: impactTime.addingTimeInterval(0.5)),
            makeSample(
                timestamp: impactTime.addingTimeInterval(1.0),
                acceleration: MotionVector(x: 0.5, y: 0.0, z: 0.0)
            )
        ]

        #expect(!validator.validate(impactTime: impactTime, samples: samples))
    }

    @Test func motionBufferPrunesSamplesOutsideWindow() {
        let baseDate = Date()
        let buffer = MotionBuffer(windowSize: 2.0)
        let oldSample = makeSample(timestamp: baseDate)
        let recentSample = makeSample(timestamp: baseDate.addingTimeInterval(3.0))

        buffer.append(oldSample)
        buffer.append(recentSample)

        #expect(buffer.recentSamples.count == 1)
        #expect(buffer.recentSamples.first?.timestamp == recentSample.timestamp)
    }

    @Test func severityScoreRebalancesWeightsWithoutBiometricBaseline() {
        let engine = SeverityScoringEngine()

        let score = engine.computeScore(
            impactMagnitude: 2.5,
            inactivityDuration: 7.5,
            currentHR: nil,
            baseline: nil
        )

        #expect(abs(score - 0.5) < 0.0001)
    }

    @Test func severityScoreCombinesImpactInactivityAndHeartRateDeviation() {
        let engine = SeverityScoringEngine()
        let baseline = UserBiometricBaseline(restingHeartRate: 60.0, averageHRV: 50.0)

        let score = engine.computeScore(
            impactMagnitude: 2.5,
            inactivityDuration: 7.5,
            currentHR: 80.0,
            baseline: baseline
        )

        #expect(abs(score - 0.5) < 0.0001)
    }

    private func makeSample(
        timestamp: Date = Date(),
        acceleration: MotionVector = MotionVector(x: 0.0, y: 0.0, z: 0.0),
        rotation: MotionVector = MotionVector(x: 0.0, y: 0.0, z: 0.0)
    ) -> MotionSample {
        MotionSample(
            timestamp: timestamp,
            acceleration: acceleration,
            rotationRate: rotation,
            attitude: AttitudeSample(pitch: 0.0, roll: 0.0, yaw: 0.0)
        )
    }
}
