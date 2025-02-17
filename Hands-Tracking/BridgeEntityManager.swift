//
//  BridgeEntityManager.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import RealityKit

class BridgeEntityManager {
    var bridgeObject: ModelEntity?
    var leftCollider: ModelEntity?
    var rightCollider: ModelEntity?

    static private let bridgeMaterials = (
        normal: SimpleMaterial(color: .gray, isMetallic: true),
        collision: SimpleMaterial(color: .yellow, isMetallic: true)
    )

    func setupBridgeAndColliders() -> (ModelEntity, ModelEntity, ModelEntity) {
        // Create bridge object with specific dimensions
        // 50 cm long (x), 5 cm high (y), 20 cm deep (z)
        let bridgeEntity = ModelEntity(
            mesh: .generateBox(size: [0.5, 0.05, 0.2]),  // Meters
            materials: [Self.bridgeMaterials.normal]
        )

        // Configure bridge for input and collision
        bridgeEntity.name = "BridgeEntity"
        bridgeEntity.components[InputTargetComponent.self] = InputTargetComponent()
        bridgeEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.5, 0.05, 0.2])])

        // Collider size adjustment
        let colliderSize: Float = 0.05
        let colliderMaterial = SimpleMaterial(color: .red.withAlphaComponent(0.5), isMetallic: false)

        // Left collider
        let leftColliderEntity = ModelEntity(
            mesh: .generateBox(size: [colliderSize, colliderSize, colliderSize]),
            materials: [colliderMaterial]
        )
        leftColliderEntity.name = "leftCollider"

        // Right collider
        let rightColliderEntity = ModelEntity(
            mesh: .generateBox(size: [colliderSize, colliderSize, colliderSize]),
            materials: [colliderMaterial]
        )
        rightColliderEntity.name = "rightCollider"

        // Set fixed position
        bridgeEntity.position = [0, 1.2, -0.5]  // Consistent initial position

        self.bridgeObject = bridgeEntity
        self.leftCollider = leftColliderEntity
        self.rightCollider = rightColliderEntity

        return (bridgeEntity, leftColliderEntity, rightColliderEntity)
    }

    func updateBridgeTransform(leftPosition: SIMD3<Float>, rightPosition: SIMD3<Float>) {
        // Do nothing - keep bridge in fixed position
    }

    func handleTap() {
        bridgeObject?.model?.materials = [Self.bridgeMaterials.collision]

        // Reset color after delay
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            bridgeObject?.model?.materials = [Self.bridgeMaterials.normal]
        }
    }
}
