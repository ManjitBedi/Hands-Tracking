//
//  ContentView.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Hands Tracking Demo")
                .font(.title)

            AirGuitarButton()

            GrabThrowButton()

            // Event display area
            VStack {
                if let event = appModel.currentEvent {
                    Text(eventMessage(for: event))
                        .foregroundColor(eventColor(for: event))
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut, value: event)
                }
            }
            .frame(height: 100)

            // Debug collision indicator
            if appModel.isColliding {
                Text("Collision Detected!")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private func eventMessage(for event: AppEvent) -> String {
        switch event {
        case .handTrackingStarted:
            return "Hand Tracking Initialized"
        case .handTrackingFailed(let message):
            return "Hand Tracking Failed: \(message)"
        case .tapDetected:
            return "Tap Detected!"
        case .collisionDetected:
            return "Collision Detected!"
        }
    }

    private func eventColor(for event: AppEvent) -> Color {
        switch event {
        case .handTrackingStarted:
            return .green
        case .handTrackingFailed:
            return .red
        case .tapDetected:
            return .blue
        case .collisionDetected:
            return .orange
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
