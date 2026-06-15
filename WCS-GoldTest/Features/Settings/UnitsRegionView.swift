import SwiftUI

enum MassUnit: String, CaseIterable {
    case grams, ounces, troyOunces
    var displayName: String {
        switch self {
        case .grams: "Grams (g)"
        case .ounces: "Ounces (oz)"
        case .troyOunces: "Troy ounces (ozt)"
        }
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius, fahrenheit
    var displayName: String {
        switch self {
        case .celsius: "Celsius (°C)"
        case .fahrenheit: "Fahrenheit (°F)"
        }
    }
}

struct UnitsRegionView: View {
    @AppStorage("massUnit") private var massUnit: MassUnit = .grams
    @AppStorage("temperatureUnit") private var temperatureUnit: TemperatureUnit = .celsius

    var body: some View {
        List {
            Section("Measurement units") {
                Picker("Mass", selection: $massUnit) {
                    ForEach(MassUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                Picker("Temperature", selection: $temperatureUnit) {
                    ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
            }

            Section("About") {
                LabeledContent("Mass units used in", value: "Scan results, vault items")
                LabeledContent("Temperature used in", value: "Device temperature readings")
            }
        }
        .navigationTitle("Units & region")
    }
}

#Preview {
    UnitsRegionView()
}
