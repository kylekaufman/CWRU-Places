import SwiftUI
import MapKit

struct MapScreen: View {
    @StateObject var viewModel = LocationViewModel()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.508, longitude: -81.611),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        Map(position: $cameraPosition) {
            // Loop through all locations and create annotations for each
            ForEach(viewModel.locations) { location in
                Annotation(location.label,
                           coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)) {

                    // Custom view for the annotation
                    VStack(spacing: 4) {
                        // Location label
                        Text(location.label)
                            .font(.callout)
                            .bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)

                        // Username
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
            // Fetch the locations when the view appears
            viewModel.fetchLocations()
            // Start the auto-refresh every 30 seconds
            viewModel.startAutoRefresh()
        }
    }
}
