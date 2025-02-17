//
//  VirtualGuitar.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import SwiftUI
import RealityKit

class VirtualGuitar {
    let dimensions: GuitarDimensions
    let entity: ModelEntity

    private let fretboardEntity: ModelEntity
    private let bodyEntity: ModelEntity
    private let stringAreaEntity: ModelEntity
    private let strumAreaEntity: ModelEntity

    private static let materials = (
        fretboard: SimpleMaterial(color: .brown, isMetallic: false),
        body: SimpleMaterial(color: .brown, isMetallic: false),
        strings: SimpleMaterial(color: .gray, isMetallic: true),
        strumArea: SimpleMaterial(color: .gray, isMetallic: true)
    )

    init(dimensions: GuitarDimensions = GuitarDimensions()) {
        self.dimensions = dimensions
        self.entity = ModelEntity()
        entity.name = "VirtualGuitar"

        // Create body first as it's our reference point
        self.bodyEntity = ModelEntity(
            mesh: .generateBox(size: dimensions.bodyDimensions),
            materials: [Self.materials.body]
        )
        bodyEntity.name = "Body"

        // Create fretboard aligned with body's left edge
        self.fretboardEntity = ModelEntity(
            mesh: .generateBox(size: dimensions.fretboardDimensions),
            materials: [Self.materials.fretboard]
        )
        fretboardEntity.name = "Fretboard"

        // Create string area centered on fretboard
        self.stringAreaEntity = ModelEntity(
            mesh: .generateBox(size: dimensions.stringAreaDimensions),
            materials: [Self.materials.strings]
        )
        stringAreaEntity.name = "StringArea"

        // Create strum area with configurable alignment
        self.strumAreaEntity = ModelEntity(
            mesh: .generateBox(size: dimensions.strumAreaDimensions),
            materials: [Self.materials.strumArea]
        )
        strumAreaEntity.name = "StrumArea"

        // Position everything
        positionComponents()

        // Assemble the guitar
        entity.addChild(bodyEntity)
        entity.addChild(fretboardEntity)
        fretboardEntity.addChild(stringAreaEntity)
        bodyEntity.addChild(strumAreaEntity)

        // Add interaction components to strum area
        setupInteraction()
    }

    private func positionComponents() {
        // Body stays at origin
        bodyEntity.position = [0, 0, 0]

        // Position fretboard relative to body's left edge
        fretboardEntity.position = [
            -(dimensions.bodyDimensions.x + dimensions.fretboardDimensions.x) * 0.5,
            (dimensions.fretboardDimensions.y - dimensions.bodyDimensions.y) * 0.5,
            0
        ]

        // Position string area on top of fretboard
        stringAreaEntity.position = [
            0,
            (dimensions.stringAreaDimensions.y + dimensions.fretboardDimensions.y) * 0.5,
            0
        ]

        // Position strum area based on alignment
        let strumX: Float
        switch dimensions.strumAreaAlignment {
        case .center:
            strumX = 0
        case .rightEdge:
            strumX = (dimensions.bodyDimensions.x - dimensions.strumAreaDimensions.x) * 0.5
        }

        strumAreaEntity.position = [
            strumX,
            (dimensions.strumAreaDimensions.y + dimensions.bodyDimensions.y) * 0.5,
            0
        ]
    }

    private func setupInteraction() {
        strumAreaEntity.collision = CollisionComponent(
            shapes: [.generateBox(size: dimensions.strumAreaDimensions)]
        )
        strumAreaEntity.components[InputTargetComponent.self] = InputTargetComponent()
    }

    func handleTap() {
        strumAreaEntity.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            strumAreaEntity.model?.materials = [Self.materials.strumArea]
        }
    }
}

// Preview support
class PreviewGuitarManager {
    let dimensions: GuitarDimensions

    init(dimensions: GuitarDimensions = GuitarDimensions()) {
        self.dimensions = dimensions
    }
}

struct HackedGuitarPreview: View {
    @State private var guitarManager: PreviewGuitarManager

    init(dimensions: GuitarDimensions = GuitarDimensions()) {
        _guitarManager = State(initialValue: PreviewGuitarManager(dimensions: dimensions))
    }

    var body: some View {
        RealityView { content in
            // Body
            let bodyEntity = ModelEntity(
                mesh: .generateBox(size: guitarManager.dimensions.bodyDimensions),
                materials: [SimpleMaterial(color: .brown, isMetallic: false)]
            )
            bodyEntity.position = [0, 0, 0]

            // Fretboard
            let fretboardEntity = ModelEntity(
                mesh: .generateBox(size: guitarManager.dimensions.fretboardDimensions),
                materials: [SimpleMaterial(color: .brown, isMetallic: false)]
            )
            fretboardEntity.position = [
                -(guitarManager.dimensions.bodyDimensions.x + guitarManager.dimensions.fretboardDimensions.x) * 0.5,
                (guitarManager.dimensions.fretboardDimensions.y - guitarManager.dimensions.bodyDimensions.y) * 0.5,
                0
            ]

            // String Area
            let stringAreaEntity = ModelEntity(
                mesh: .generateBox(size: guitarManager.dimensions.stringAreaDimensions),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            stringAreaEntity.position = [
                0,
                (guitarManager.dimensions.stringAreaDimensions.y + guitarManager.dimensions.fretboardDimensions.y) * 0.5,
                0
            ]

            // Strum Area
            let strumAreaEntity = ModelEntity(
                mesh: .generateBox(size: guitarManager.dimensions.strumAreaDimensions),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )

            let strumX: Float = guitarManager.dimensions.strumAreaAlignment == .center ? 0 :
                (guitarManager.dimensions.bodyDimensions.x - guitarManager.dimensions.strumAreaDimensions.x) * 0.5

            strumAreaEntity.position = [
                strumX,
                (guitarManager.dimensions.strumAreaDimensions.y + guitarManager.dimensions.bodyDimensions.y) * 0.5,
                0
            ]

            // Create a parent entity to group all parts
            let guitarEntity = ModelEntity()
            guitarEntity.addChild(bodyEntity)
            guitarEntity.addChild(fretboardEntity)
            fretboardEntity.addChild(stringAreaEntity)
            bodyEntity.addChild(strumAreaEntity)

            // Rotate the entire guitar entity
            guitarEntity.orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])

            content.add(guitarEntity)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    HackedGuitarPreview()
}

#Preview("Right-aligned Strum Area", windowStyle: .volumetric) {
    HackedGuitarPreview(dimensions: {
        var dims = GuitarDimensions()
        dims.strumAreaAlignment = .rightEdge
        return dims
    }())
}
