import SwiftUI
import MapKit

struct MapScreen: View {
    @StateObject var viewModel = LocationViewModel()
    @ObservedObject private var locationManager = LocationManager.shared
    @State var tag: String
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.508, longitude: -81.611),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                ForEach(viewModel.locations) { location in
                    Annotation(location.label,
                               coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)) {
                        VStack(spacing: 4) {
                            Text(location.label)
                                .font(.callout)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 3)

                            Text(location.user)
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(4)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                                .shadow(radius: 1)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                locationManager.requestLocation()
                Task {
                    do {
                        try await viewModel.fetchLocations()
                        viewModel.startAutoRefresh()
                    } catch {
                        print("❌ Failed to fetch locations: \(error.localizedDescription)")
                    }
                }
            }

            HStack(spacing: 12) {
                TextField("Enter tag...", text: $tag)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                Button(action: {
                    Task {
                        do {
                            guard let location = locationManager.currentLocation else {
                                throw NetworkError.noData
                            }

                            let myLocation = Location(
                                user: "elm102",
                                lat: location.coordinate.latitude,
                                lng: location.coordinate.longitude,
                                label: tag,
                                pass: "3525684"
                            )

                            let result = try await viewModel.shareLocation(myLocation)
                            print("✅ Location tagged: \(result)")
                            try await viewModel.fetchLocations()
                            tag = ""
                        } catch {
                            print("⚠️ Failed to tag location: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Label("Tag Location", systemImage: "mappin.and.ellipse")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MapScreen(tag: "")
}
