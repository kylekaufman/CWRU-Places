import Foundation

struct Location: Identifiable, Codable {
    var id: String { user }
    let user: String
    let lat: Double
    let lng: Double
    let label: String
    let pass: String?
}

struct LocationResponse: Codable {
    let locations: [Location]
}
