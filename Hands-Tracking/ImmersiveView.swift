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
    @Environment(AppModel.self) private var appModel
    @StateObject private var handTrackingManager = HandTrackingManager()
    @State private var debugSpheres: [ModelEntity] = []
    @State private var bridgeEntity: ModelEntity?
    private let bridgeManager = BridgeEntityManager()
    private let audioEngine = AudioEngine()

    // Add a state to track last tap time to prevent rapid repeated taps
    @State private var lastTapTime = Date.distantPast

    var body: some View {
        RealityView { content in
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

                let (bridge, leftCollider, rightCollider) = bridgeManager.setupBridgeAndColliders()

                content.add(bridge)
                content.add(leftCollider)
                content.add(rightCollider)

                // Store bridge entity for gesture
                bridgeEntity = bridge

                try? audioEngine.start()
            }
        } update: { content in
            updatePositions()
        }.gesture(
            SpatialTapGesture()
                .targetedToEntity(bridgeManager.bridgeObject ?? Entity())
                .onEnded { _ in
                    // Basic tap handling
                    appModel.handleTap()

                    // Play a C major chord
                    let chordNotes = [
                        (note: MusicalNote.C, octave: 4),
                        (note: MusicalNote.E, octave: 4),
                        (note: MusicalNote.G, octave: 4)
                    ]
                    audioEngine.playChord(chordNotes, velocity: 0.7)

                    // Update visual state
                    bridgeManager.handleTap()

                    // Update app state
                    appModel.handleCollision()
                }
        ).task {
            await handTrackingManager.setupHandTracking()
        }
    }

    private func updatePositions() {
        let visibleHands = handTrackingManager.handPositions.prefix(2)

        for (index, hand) in visibleHands.enumerated() {
            guard index < debugSpheres.count else { break }

            let transform = hand.originFromAnchorTransform
            let position = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z)

            let sphere = debugSpheres[index]
            sphere.position = position
            sphere.isEnabled = true

            if index == 0 && debugSpheres.count > 1 { // Left hand and right sphere exists
                bridgeManager.updateBridgeTransform(
                    leftPosition: position,
                    rightPosition: debugSpheres[1].position
                )
            }
        }

        // Hide spheres for hands that aren't visible
        for i in visibleHands.count..<debugSpheres.count {
            debugSpheres[i].isEnabled = false
        }
    }
}
