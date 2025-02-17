//
//  VirtualGuitarEntityManager.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//


import RealityKit

class VirtualGuitarEntityManager {
    var guitarEntity: ModelEntity?
    var fretboardEntity: ModelEntity?
    var stringAreaEntity: ModelEntity?
    var bodyEntity: ModelEntity?
    var strumAreaEntity: ModelEntity?
    var colliderEntity: ModelEntity?

    static private let guitarMaterials = (
        body: SimpleMaterial(color: .brown, isMetallic: false),
        fretboard: SimpleMaterial(color: .brown, isMetallic: false),
        stringArea: SimpleMaterial(color: .gray, isMetallic: true),
        strumArea: SimpleMaterial(color: .lightGray, isMetallic: true),
        collider: SimpleMaterial(color: .red, isMetallic: false)
    )

    func setupGuitarEntity() -> ModelEntity {
        // Create the main guitar entity
        let guitarEntity = ModelEntity()
        guitarEntity.name = "VirtualGuitar"

        // Fretboard - positioned on the left
        let fretboardEntity = ModelEntity(
            mesh: .generateBox(size: [0.2, 0.02, 0.1]),  // Narrower fretboard
            materials: [Self.guitarMaterials.fretboard]
        )
        fretboardEntity.name = "Fretboard"
        fretboardEntity.position = [-0.3, 0.02, 0]  // Positioned to the left

        // Guitar Body - positioned to the right of fretboard
        let bodyEntity = ModelEntity(
            mesh: .generateBox(size: [0.3, 0.05, 0.2]),  // Wider body
            materials: [Self.guitarMaterials.body]
        )
        bodyEntity.name = "Body"
        bodyEntity.position = [0, 0, 0]  // Centered after fretboard

        // Collider Area - raised section on the body
        let colliderEntity = ModelEntity(
            mesh: .generateBox(size: [0.1, 0.03, 0.05]),  // Slightly raised
            materials: [Self.guitarMaterials.collider]
        )
        colliderEntity.name = "Collider"
        colliderEntity.position = [0.1, 0.04, 0]  // Raised and positioned on the body
        colliderEntity.collision = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.03, 0.05])])
        colliderEntity.components[InputTargetComponent.self] = InputTargetComponent()

        // String Area - thin rectangular area
        let stringAreaEntity = ModelEntity(
            mesh: .generateBox(size: [0.2, 0.01, 0.08]),
            materials: [Self.guitarMaterials.stringArea]
        )
        stringAreaEntity.name = "StringArea"
        stringAreaEntity.position = [-0.25, 0.03, 0]  // Positioned on fretboard

        // Assemble the guitar
        guitarEntity.addChild(fretboardEntity)
        guitarEntity.addChild(bodyEntity)
        guitarEntity.addChild(stringAreaEntity)
        guitarEntity.addChild(colliderEntity)

        // Position the entire guitar lower and slightly angled
        guitarEntity.position = [0, 0.8, -0.5]  // Lower than previous position
        guitarEntity.orientation = simd_quatf(angle: -0.2, axis: [1, 0, 0])  // Slight downward angle

        // Store references
        self.guitarEntity = guitarEntity
        self.fretboardEntity = fretboardEntity
        self.bodyEntity = bodyEntity
        self.stringAreaEntity = stringAreaEntity
        self.colliderEntity = colliderEntity

        return guitarEntity
    }

    func handleTap() {
        // Temporary visual feedback
        colliderEntity?.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]

        // Reset color after delay
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            colliderEntity?.model?.materials = [Self.guitarMaterials.collider]
        }
    }
}
