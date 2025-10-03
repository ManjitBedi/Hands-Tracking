//
//  ManipulateView.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-10-03.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ManipulateView: View {
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                guard let group = immersiveContentEntity.findEntity(named: "Manipulatives")
                else { return }

                for child in group.children {
                    ManipulationComponent.configureEntity(child)
                    child.components[ManipulationComponent.self]?.releaseBehavior = .stay
                }
            }
        }
    }
}

#Preview {
    ManipulateView()
}
