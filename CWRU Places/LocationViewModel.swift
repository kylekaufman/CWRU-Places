import Foundation
import Combine
import MapKit

@MainActor
class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []

    func fetchLocations() async throws {
        guard let url = URL(string: "https://caslab.case.edu/392/map.php") else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        do {
            let decoded = try JSONDecoder().decode(LocationResponse.self, from: data)
            self.locations = decoded.locations
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    func shareLocation(_ location: Location) async throws -> String {
        guard let url = URL(string: "https://caslab.case.edu/392/map.php") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(location)
        } catch {
            throw NetworkError.encodingFailed(error)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidStatus((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        guard let responseString = String(data: data, encoding: .utf8) else {
            throw NetworkError.responseConversionFailed
        }

        return responseString
    }

    func startAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                do {
                    try await self.fetchLocations()
                } catch {
                    print("Auto-refresh error: \(error.localizedDescription)")
                }
            }
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidStatus(Int)
    case noData
    case decodingFailed(Error)
    case encodingFailed(Error)
    case responseConversionFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidStatus(let code):
            return "Server responded with HTTP \(code)."
        case .noData:
            return "No data received from server."
        case .decodingFailed(let err):
            return "Decoding failed: \(err.localizedDescription)"
        case .encodingFailed(let err):
            return "Encoding failed: \(err.localizedDescription)"
        case .responseConversionFailed:
            return "Failed to convert response to string."
        }
    }
}
