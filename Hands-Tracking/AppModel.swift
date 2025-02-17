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

enum AppEvent: Equatable {
    case handTrackingStarted
    case handTrackingFailed(String)
    case tapDetected
    case collisionDetected
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

    var handPositions: [HandAnchor] = []
    var currentEvent: AppEvent?

    private var session: ARKitSession?
    private var handTracking: HandTrackingProvider?

    var isColliding = false

    // Timer for resetting collision state
    private var collisionTimer: Timer?
    private var eventClearTimer: Timer?

    init() {
#if !targetEnvironment(simulator)
        Task {
            await setupHandTracking()
        }
#endif
    }

    @MainActor
    private func setupHandTracking() async {
        session = ARKitSession()
        handTracking = HandTrackingProvider()

        guard let session = session,
              let handTracking = handTracking else {
            updateEvent(.handTrackingFailed("Session initialization failed"))
            return
        }

        do {
            authorizationState = .authorized
            try await session.run([handTracking])

            updateEvent(.handTrackingStarted)

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
            updateEvent(.handTrackingFailed(error.localizedDescription))
            authorizationState = .denied
        }
    }

    func handleTap() {
        updateEvent(.tapDetected)
    }

    func handleCollision() {
        updateEvent(.collisionDetected)
        isColliding = true
        collisionTimer?.invalidate()
        collisionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.isColliding = false
            }
        }
    }

    private func updateEvent(_ event: AppEvent) {
        currentEvent = event

        // Clear the event after a short delay
        eventClearTimer?.invalidate()
        eventClearTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.currentEvent = nil
            }
        }
    }
}
