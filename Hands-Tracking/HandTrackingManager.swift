//
//  HandTrackingManager.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import ARKit
import RealityKit

class HandTrackingManager: ObservableObject {
    @Published var handPositions: [HandAnchor] = []
    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    func setupHandTracking() async {
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

    @MainActor
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
