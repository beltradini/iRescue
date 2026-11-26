//
//  MonitoringView.swift
//  iRescue
//
//  Created by Alejandro Beltrán on 6/23/26.
//

import SwiftUI

struct MonitoringView: View {
    @StateObject private var viewModel = MonitoringViewModel()

    var body: some View {
        VStack(spacing: 8) {
            statusHeader

            HStack(spacing: 6) {
                metricCard(title: "Accel", value: viewModel.currentAcceleration, unit: "g")
                metricCard(title: "Rotation", value: viewModel.currentRotation, unit: "rad/s")
            }

            heartRateCard

            Button(viewModel.isMonitoring ? "Stop" : "Start") {
                if viewModel.isMonitoring {
                    viewModel.stopMonitoring()
                } else {
                    viewModel.startMonitoring()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isMonitoring ? .red : .accentColor)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.black)
    }

    private var statusHeader: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.16))
                    .frame(width: 36, height: 36)

                Image(systemName: statusIcon)
                    .font(.headline)
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(statusTitle)
                    .font(.headline)

                Text(statusSubtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heartRateCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text("Heart Rate")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                if let heartRate = viewModel.heartRate {
                    Text("\(heartRate, specifier: "%.0f") bpm")
                        .font(.system(.headline, design: .rounded))
                        .monospacedDigit()
                } else {
                    Text("-- bpm")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(7)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var statusIcon: String {
        switch viewModel.systemStatus {
        case .idle:
            return "pause.circle"
        case .monitoring:
            return "heart.circle"
        case .alert:
            return "exclamationmark.triangle.fill"
        }
    }

    private var statusTitle: String {
        switch viewModel.systemStatus {
        case .idle:
            return "Idle"
        case .monitoring:
            return "Monitoring"
        case .alert:
            return "Alert"
        }
    }

    private var statusSubtitle: String {
        switch viewModel.systemStatus {
        case .idle:
            return "Ready"
        case .monitoring:
            return "Analyzing signals"
        case .alert:
            return "Critical event detected"
        }
    }

    private var statusColor: Color {
        switch viewModel.systemStatus {
        case .idle:
            return .secondary
        case .monitoring:
            return .green
        case .alert:
            return .red
        }
    }

    private func metricCard(title: String, value: Double, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value, format: .number.precision(.fractionLength(1)))
                    .font(.system(.headline, design: .rounded))
                    .monospacedDigit()

                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(7)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
