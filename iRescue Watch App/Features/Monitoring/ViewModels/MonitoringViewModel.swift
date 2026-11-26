//
//  MonitoringViewModel.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 6/23/26.
//

import Foundation
import Combine

@MainActor
final class MonitoringViewModel: ObservableObject {
    
    @Published var isMonitoring = false
    @Published var currentAcceleration: Double = 0.0
    @Published var currentRotation: Double = 0.0
    @Published var heartRate: Double?
    @Published var lastEventTime: Date?
    @Published var systemStatus: SystemStatus = .idle
    
    private let motionManager: MotionCaptureManager
    private let healthManager: HealthMonitorManager
    private var criticalEventEngine: CriticalEventEngine!
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SystemStatus {
        case idle
        case monitoring
        case alert
    }
    
    convenience init() {
        self.init(
            motionManager: MotionCaptureManager(),
            healthManager: HealthMonitorManager()
        )
    }
    
    init(
        motionManager: MotionCaptureManager,
        healthManager: HealthMonitorManager
    ) {
        self.motionManager = motionManager
        self.healthManager = healthManager
        self.criticalEventEngine = CriticalEventEngine(
            motionManager: motionManager,
            heartRateProvider: { healthManager.latestHeartRate }
        ) { [weak self] event in
            Task { @MainActor in
                self?.handleCriticalEvent(event)
            }
        }

        setupBindings()
    }
    
    private func setupBindings() {
        motionManager.$latestSample
            .compactMap { $0 }
            .sink { [weak self] sample in
                guard let self = self else { return }
                
                self.currentAcceleration = sample.acceleration.magnitude
                self.currentRotation = sample.rotationRate.magnitude
            }
            .store(in: &cancellables)
        
        // Heart rate bindings
        healthManager.$latestHeartRate
            .sink { [weak self] in
                self?.heartRate = $0
            }
            .store(in: &cancellables)
        
        // Monitoring state
        motionManager.$isCapturing
            .sink { [weak self] in
                self?.isMonitoring = $0
                self?.systemStatus = $0 ? .monitoring : .idle
            }
            .store(in: &cancellables)
    }
    
    func startMonitoring() {
        Task {
            if await healthManager.requestAuthorization() {
                healthManager.startHeartRateUpdates()
            }
        }
        criticalEventEngine.startMonitoring()
    }

    func stopMonitoring() {
        criticalEventEngine.stopMonitoring()
        healthManager.stopHeartRateUpdates()
    }

    private func handleCriticalEvent(_ event: CriticalEvent) {
        lastEventTime = event.timestamp
        systemStatus = .alert
    }
}
