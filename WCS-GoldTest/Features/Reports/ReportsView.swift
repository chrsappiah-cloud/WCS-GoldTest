import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @State private var reports: [ReportRecord] = []
    private var canUseReports: Bool {
        dependencies.accessControl.canAccess(.pdfReports).allowed
    }

    var body: some View {
        NavigationStack {
            Group {
                if !canUseReports {
                    ContentUnavailableView(
                        "Reports locked",
                        systemImage: "lock.fill",
                        description: Text(dependencies.accessControl.canAccess(.pdfReports).reason)
                    )
                } else if reports.isEmpty {
                    ContentUnavailableView(
                        "No reports yet",
                        systemImage: "doc.richtext",
                        description: Text("Generate a certificate-style PDF from a saved scan.")
                    )
                } else {
                    List(reports) { report in
                        ReportRow(report: report)
                    }
                }
            }
            .wcsLuxuryScreen()
            .navigationTitle("Reports")
            .task {
                reports = (try? await dependencies.reportRepository.fetchAll()) ?? []
            }
        }
    }
}

struct ReportRow: View {
    let report: ReportRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(report.createdAt, style: .date)
                .font(.headline)
            Text(report.status.rawValue.capitalized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .swipeActions {
            if report.status == .ready, let url = report.pdfURL {
                ShareLink(item: url) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}
