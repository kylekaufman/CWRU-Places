import Foundation
import Combine
import MapKit

class LocationViewModel: ObservableObject {
    @Published var locations: [Location] = []

    func fetchLocations() {
        guard let url = URL(string: "https://caslab.case.edu/392/map.php") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("Error: \(error?.localizedDescription ?? "No data")")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(LocationResponse.self, from: data)
                DispatchQueue.main.async {
                    self.locations = decoded.locations
                }
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }

    func startAutoRefresh() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            self.fetchLocations()
        }
    }
}
