//
//  AppModel.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import SwiftUI
import ARKit

enum AuthorizationState {
    case notDetermined
    case authorized
    case denied
}


/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var authorizationState: AuthorizationState = .notDetermined

    private var handTrackingSession: ARKitSession?

    var handPositions: [HandAnchor] = []

    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    init() {
        Task {
            await setupHandTracking()
        }
    }

    @MainActor
    private func setupHandTracking() async {
        session = ARKitSession()
        handTracking = HandTrackingProvider()

        guard let session = session,
              let handTracking = handTracking else { return }

        do {
            authorizationState = .authorized  // Explicitly set authorization
            try await session.run([handTracking])

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
        } catch {
            print("Failed to initialize hand tracking: \(error)")
            authorizationState = .denied
        }
    }
}
