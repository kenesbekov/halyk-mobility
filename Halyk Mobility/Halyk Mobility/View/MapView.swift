//
//  MapView.swift
//  Halyk Mobility
//
//  Created by Adam Kenesbekov on 11.11.2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Add a Core Location manager
    @State private var locationManager = CLLocationManager()

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear {
                // Request location permission
                locationManager.requestWhenInUseAuthorization()

                // Set the delegate to receive location updates
                locationManager.delegate = Coordinator(self)
                locationManager.startUpdatingLocation()
            }
    }

    private class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // Update the region when the location changes
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first?.coordinate {
                parent.region.center = location
            }
        }
    }
}

#Preview {
    MapView()
}
