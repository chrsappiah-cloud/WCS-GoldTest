import SwiftUI

struct ScanTabView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        ScanRootViewWrapper(dependencies: dependencies)
    }
}

private struct ScanRootViewWrapper: View {
    let dependencies: AppDependencies
    @StateObject private var viewModel: GoldScanViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _viewModel = StateObject(wrappedValue: dependencies.makeGoldScanViewModel())
    }

    var body: some View {
        ScanRootView(viewModel: viewModel)
    }
}

struct ScanRootView: View {
    @ObservedObject var viewModel: GoldScanViewModel
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle, .checklist:
                    ScanSetupView(viewModel: viewModel)
                case .scanning:
                    ScanLiveView(viewModel: viewModel)
                case .completed:
                    if let result = viewModel.result {
                        ScanResultSheet(result: result) {
                            viewModel.reset()
                        }
                    }
                case .failed:
                    ScanSetupView(viewModel: viewModel)
                }
            }
            .navigationTitle("Scan")
            .wcsLuxuryScreen()
            .accessibilityIdentifier(AccessibilityID.Scan.screen)
        }
    }
}

struct ScanSetupView: View {
    @ObservedObject var viewModel: GoldScanViewModel
    @EnvironmentObject private var dependencies: AppDependencies

    private func materialEnabled(_ material: MaterialType) -> Bool {
        dependencies.accessControl.canStartScan(material: material).allowed
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Material")
                    .font(.headline)
                    .foregroundStyle(WCSTheme.primaryText)
                Picker("Material", selection: $viewModel.selectedMaterial) {
                    ForEach(MaterialType.allCases) { material in
                        Label(material.displayName, systemImage: material.systemImage)
                            .tag(material)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(!ProcessInfo.processInfo.arguments.contains("-ui-testing") && !materialEnabled(viewModel.selectedMaterial))

                WCSCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pre-scan checklist")
                            .font(.headline)
                        Toggle("Probe cleaned and seated", isOn: $viewModel.checklistComplete)
                            .accessibilityIdentifier(AccessibilityID.Scan.checklistToggle)
                        Toggle("Item surface dry and accessible", isOn: $viewModel.surfaceDryAccessible)
                        Toggle("Stable hand position", isOn: $viewModel.stableHandPosition)
                    }
                }

                Text(LegalCopy.scanDisclaimer)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                WCSPrimaryButton(
                    "Start Gold Scan",
                    systemImage: "dot.radiowaves.left.and.right",
                    accessibilityIdentifier: AccessibilityID.Scan.startGoldScan
                ) {
                    Task { await viewModel.startScan() }
                }
                .disabled(!viewModel.checklistComplete || !viewModel.surfaceDryAccessible || !viewModel.stableHandPosition || (!ProcessInfo.processInfo.arguments.contains("-ui-testing") && viewModel.selectedMaterial != .gold))
            }
            .padding()
        }
    }
}

struct ScanLiveView: View {
    @ObservedObject var viewModel: GoldScanViewModel

    var body: some View {
        VStack(spacing: 24) {
            ProgressView("Measuring…")
                .font(.headline)

            SignalChartView(samples: viewModel.liveSignal)
                .frame(height: 180)
                .padding(.horizontal)

            Text("Hold steady against the item")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SignalChartView: View {
    let samples: [Double]

    var body: some View {
        GeometryReader { geo in
            let maxVal = max(samples.max() ?? 1, 0.01)
            Path { path in
                guard samples.count > 1 else { return }
                for (index, value) in samples.enumerated() {
                    let x = geo.size.width * CGFloat(index) / CGFloat(samples.count - 1)
                    let y = geo.size.height * (1 - CGFloat(value / maxVal))
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(WCSTheme.goldGradient, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .shadow(color: WCSTheme.goldMid.opacity(0.4), radius: 4)
        }
        .background(WCSTheme.cardBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ScanResultSheet: View {
    let result: ScanResult
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Screening result")
                    .font(.title2.bold())
                    .foregroundStyle(WCSTheme.primaryText)

                WCSCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.classification)
                            .font(.title3.weight(.semibold))
                        if let karat = result.estimatedKarat, let purity = result.estimatedPurityPercent {
                            Text("Estimated \(Int(karat))K · \(purity, format: .number.precision(.fractionLength(1)))% purity")
                                .foregroundStyle(.secondary)
                        }
                        WCSConfidenceBadge(confidence: result.confidence)
                    }
                }

                if !result.warnings.isEmpty {
                    WCSCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Warnings")
                                .font(.headline)
                            ForEach(result.warnings, id: \.self) { warning in
                                Label(warning, systemImage: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                    .font(.subheadline)
                            }
                        }
                    }
                }

                Text(WCSTheme.disclaimer)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                WCSPrimaryButton("Done", systemImage: "checkmark") {
                    onDismiss()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScanTabView()
        .environmentObject(AppDependencies())
}
