//
//  MotionCaptureManager.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 2/24/26.
//

import CoreMotion
import Combine

final class MotionCaptureManager {
    
    private let motionManager = CMMotionManager()
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.irescue.motion-capture"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    @Published private(set) var latestSample: MotionSample?
    @Published private(set) var isCapturing: Bool = false
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0
        
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, _ in
            guard let motion = motion else { return }
            
            let sample = MotionSample(
                timestamp: Date(),
                acceleration: MotionVector(
                    x: motion.userAcceleration.x,
                    y: motion.userAcceleration.y,
                    z: motion.userAcceleration.z
                ),
                rotationRate: MotionVector(
                    x: motion.rotationRate.x,
                    y: motion.rotationRate.y,
                    z: motion.rotationRate.z
                ),
                attitude: AttitudeSample(
                    pitch: motion.attitude.pitch,
                    roll: motion.attitude.roll,
                    yaw: motion.attitude.yaw
                )
            )
            
            DispatchQueue.main.async {
                self?.isCapturing = true
                self?.latestSample = sample
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        DispatchQueue.main.async {
            self.isCapturing = false
        }
    }
}
