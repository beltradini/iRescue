//
//  CriticalEventEngine.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation
import Combine

final class CriticalEventEngine {
    
    private let motionManager: MotionCaptureManager
    private let analyzer = ImpactAnalyzer()
    private let classifier = EventClassifier()
    private let severityScoringEngine = SeverityScoringEngine()
    private let buffer = MotionBuffer()
    private let inactivityValidator = InactivityValidator()
    private let heartRateProvider: () -> Double?
    private let eventHandler: (CriticalEvent) -> Void
    private let validationTimeout: TimeInterval = 12
    
    private var cancellables = Set<AnyCancellable>()
    private var pendingImpact: MotionSample?
    
    init(
        motionManager: MotionCaptureManager,
        heartRateProvider: @escaping () -> Double? = { nil },
        eventHandler: @escaping (CriticalEvent) -> Void
    ) {
        self.motionManager = motionManager
        self.heartRateProvider = heartRateProvider
        self.eventHandler = eventHandler
    }
    
    func startMonitoring() {
        guard cancellables.isEmpty else {
            motionManager.start()
            return
        }

        motionManager.$latestSample
            .compactMap { $0 }
            .sink { [weak self] sample in
                self?.process(sample)
            }
            .store(in: &cancellables)
        
        motionManager.start()
    }

    func stopMonitoring() {
        motionManager.stop()
        cancellables.removeAll()
        pendingImpact = nil
    }

    private func process(_ sample: MotionSample) {
        buffer.append(sample)
        
        if let impact = pendingImpact {
            if inactivityValidator.validate(impactTime: impact.timestamp, samples: buffer.recentSamples) {
                if let event = classifier.classify(sample: impact) {
                    let severityScore = severityScoringEngine.computeScore(
                        impactMagnitude: impact.acceleration.magnitude,
                        inactivityDuration: sample.timestamp.timeIntervalSince(impact.timestamp),
                        currentHR: heartRateProvider(),
                        baseline: nil
                    )
                    
                    handle(
                        event: CriticalEvent(
                            type: event.type,
                            severityScore: severityScore,
                            timestamp: event.timestamp
                        )
                    )
                }
                pendingImpact = nil
            } else if sample.timestamp.timeIntervalSince(impact.timestamp) >= validationTimeout {
                pendingImpact = nil
            }
            return
        }
        
        if analyzer.analyze(sample: sample) {
            pendingImpact = sample
        }
    }

    private func handle(event: CriticalEvent) {
        eventHandler(event)
    }
}
