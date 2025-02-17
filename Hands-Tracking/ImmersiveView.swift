//
//  ImmersiveView.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import ARKit
import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @State private var handPositions: [HandAnchor] = []
    @State private var debugSpheres: [ModelEntity] = []
    @State private var session: ARKitSession?
    @State private var handTracking: HandTrackingProvider?

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Create debug spheres for hands
                debugSpheres = (0...1).map { index in
                    let sphere = ModelEntity(
                        mesh: .generateSphere(radius: 0.05),
                        materials: [SimpleMaterial(color: index == 0 ? .blue : .green, isMetallic: true)]
                    )
                    content.add(sphere)
                    sphere.position = [Float(index) * 0.3 - 0.15, 1.2, -0.5]
                    return sphere
                }

            }
        } update: { content in
            updateHandPositions()
        }
        .task {
            await setupHandTracking()
        }
    }

    private func updateHandPositions() {
        let visibleHands = handPositions.prefix(2)

        // Update hand positions and spheres
        for (index, hand) in visibleHands.enumerated() {
            guard index < debugSpheres.count else { break }

            // Get position from transform
            let transform = hand.originFromAnchorTransform
            let position = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z)

            let sphere = debugSpheres[index]
            sphere.position = position
            sphere.isEnabled = true

        }
    }

    private func setupHandTracking() async {
        print("Setting up hand tracking")
        session = ARKitSession()
        handTracking = HandTrackingProvider()

        guard let session = session,
            let handTracking = handTracking
        else { return }

        do {
            try await session.run([handTracking])
            print("Hand tracking session started")
            await processHandTrackingUpdates(handTracking)
        } catch {
            print("Failed to initialize hand tracking: \(error)")
        }
    }

    private func processHandTrackingUpdates(_ handTracking: HandTrackingProvider) async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                if let index = handPositions.firstIndex(where: { $0.id == update.anchor.id }) {
                    handPositions[index] = update.anchor
                } else {
                    handPositions.append(update.anchor)
                }
            case .removed:
                handPositions.removeAll(where: { $0.id == update.anchor.id })
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
