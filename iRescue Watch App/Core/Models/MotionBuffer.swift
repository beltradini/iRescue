//
//  MotionBuffer.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import Foundation

final class MotionBuffer {
    
    private var samples: [MotionSample] = []
    private let windowSize: TimeInterval
    
    init(windowSize: TimeInterval = 15.0) {
        self.windowSize = windowSize
    }
    
    func append(_ sample: MotionSample) {
        samples.append(sample)
        pruneOldSamples(relativeTo: sample.timestamp)
    }
    
    private func pruneOldSamples(relativeTo date: Date) {
        let cutoff = date.addingTimeInterval(-windowSize)
        samples.removeAll { $0.timestamp < cutoff }
    }
    
    var recentSamples: [MotionSample] {
        samples
    }
}
