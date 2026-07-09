//
//  TrackMap.swift
//  CH4
//
//  Created by Ni Komang Ayu Juliana on 08/07/26.
//

import SwiftUI
import MapKit

struct TrackMapView: View {
    
    var coordinates: [CLLocationCoordinate2D]

    @State private var session = RunSessionManager.shared
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(Color.orange, lineWidth: 3)
            }
            if let start = coordinates.first {
                Marker("Start", coordinate: start)
                    .tint(.green)
            }
            if coordinates.count > 1, let current = coordinates.last {
                Marker("Now", coordinate: current)
                    .tint(.orange)
            }
        }
        .disabled(true)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: coordinates.count) { _, _ in
            recenter()
        }
        .onAppear { recenter() }
    }

    private func recenter() {
        guard let last = coordinates.last else { return }
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: last,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            )
        }
    }

}

//#Preview {
//    TrackMapView(coordinates: [
//        CLLocationCoordinate2D(latitude: -8.409518, longitude: 115.188919),
//        CLLocationCoordinate2D(latitude: -8.410518, longitude: 115.189919)
//    ])
//    .frame(width: 150, height: 90)
//}
