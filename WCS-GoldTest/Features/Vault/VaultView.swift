import SwiftData
import SwiftUI

struct VaultView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @Query(sort: \PersistedVaultItem.createdAt, order: .reverse) private var items: [PersistedVaultItem]
    @State private var searchText = ""
    @State private var materialFilter: MaterialType?

    private var filtered: [PersistedVaultItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
            let matchesMaterial = materialFilter == nil
                || item.materialRaw == materialFilter?.rawValue
            return matchesSearch && matchesMaterial
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "No saved items",
                        systemImage: "tray",
                        description: Text("Completed scans appear here.")
                    )
                } else {
                    ForEach(filtered, id: \.id) { item in
                        VaultRow(item: item.domainModel)
                    }
                }
            }
            .wcsLuxuryScreen()
            .navigationTitle("Vault")
            .searchable(text: $searchText, prompt: "Search vault")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu("Filter") {
                        Button("All materials") { materialFilter = nil }
                        ForEach(MaterialType.allCases) { material in
                            Button(material.displayName) { materialFilter = material }
                        }
                    }
                }
            }
        }
    }
}

struct VaultRow: View {
    let item: VaultItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.thumbnailSystemImage)
                .font(.title2)
                .foregroundStyle(WCSTheme.goldGradient)
                .frame(width: 44, height: 44)
                .background(WCSTheme.cardBackground, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.material.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let purity = item.latestPurityPercent {
                    Text("\(purity, format: .number.precision(.fractionLength(1)))% · \(Int(item.confidence * 100))% confidence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(item.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
