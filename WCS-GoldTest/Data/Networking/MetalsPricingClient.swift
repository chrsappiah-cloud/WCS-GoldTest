import Foundation

struct MetalRatesResponse: Decodable, Sendable {
    let success: Bool
    let base: String
    let rates: [String: Double]
}

final class MetalsPricingClient: Sendable {
    private let session: URLSession
    private let apiKey: String

    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func latest() async throws -> MetalRatesResponse {
        var components = URLComponents(string: "https://api.metalpriceapi.com/v1/latest")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "base", value: "USD"),
            URLQueryItem(name: "currencies", value: "XAU,XAG,XPT,AUD"),
        ]
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode(MetalRatesResponse.self, from: data)
    }
}
