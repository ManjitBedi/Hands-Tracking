//
//  VirtualGuitar.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import SwiftUI
import RealityKit


struct VirtualGuitarConfig {
    // Fretboard Configuration
    var fretboardLength: Float = 0.2
    var fretboardHeight: Float = 0.02
    var fretboardWidth: Float = 0.1
    var fretboardXOffset: Float = -0.3
    var fretboardYOffset: Float = 0.02

    // Body Configuration
    var bodyLength: Float = 0.3
    var bodyHeight: Float = 0.05
    var bodyWidth: Float = 0.2
    var bodyXOffset: Float = 0
    var bodyYOffset: Float = 0

    // Tap Area Configuration
    var tapAreaLength: Float = 0.1
    var tapAreaHeight: Float = 0.03
    var tapAreaWidth: Float = 0.05
    var tapAreaXOffset: Float = 0.1
    var tapAreaYOffset: Float = 0.04

    // Overall Guitar Positioning
    var guitarXPosition: Float = 0
    var guitarYPosition: Float = 0.8
    var guitarZPosition: Float = -0.5
    var guitarAngle: Float = -0.2
}

class VirtualGuitar {
    let config: VirtualGuitarConfig
    let entity: ModelEntity

    private let fretboardEntity: ModelEntity
    private let bodyEntity: ModelEntity
    private let tapAreaEntity: ModelEntity

    private static let materials = (
        fretboard: SimpleMaterial(color: .green, isMetallic: false),
        body: SimpleMaterial(color: .brown, isMetallic: false),
        tapArea: SimpleMaterial(color: .gray, isMetallic: true)
    )

    init(config: VirtualGuitarConfig = VirtualGuitarConfig()) {
        self.config = config

        // Create the main guitar entity
        self.entity = ModelEntity()
        entity.name = "VirtualGuitar"

        // Create Fretboard
        self.fretboardEntity = ModelEntity(
            mesh: .generateBox(size: [
                config.fretboardLength,
                config.fretboardHeight,
                config.fretboardWidth
            ]),
            materials: [Self.materials.fretboard]
        )
        fretboardEntity.name = "Fretboard"
        fretboardEntity.position = [
            config.fretboardXOffset,
            config.fretboardYOffset,
            0
        ]

        // Create Body
        self.bodyEntity = ModelEntity(
            mesh: .generateBox(size: [
                config.bodyLength,
                config.bodyHeight,
                config.bodyWidth
            ]),
            materials: [Self.materials.body]
        )
        bodyEntity.name = "Body"
        bodyEntity.position = [
            config.bodyXOffset,
            config.bodyYOffset,
            0
        ]

        // Create Tap Area
        self.tapAreaEntity = ModelEntity(
            mesh: .generateBox(size: [
                config.tapAreaLength,
                config.tapAreaHeight,
                config.tapAreaWidth
            ]),
            materials: [Self.materials.tapArea]
        )
        tapAreaEntity.name = "TapArea"
        tapAreaEntity.position = [
            config.tapAreaXOffset,
            config.tapAreaYOffset,
            0
        ]
        tapAreaEntity.collision = CollisionComponent(shapes: [
            .generateBox(size: [
                config.tapAreaLength,
                config.tapAreaHeight,
                config.tapAreaWidth
            ])
        ])
        tapAreaEntity.components[InputTargetComponent.self] = InputTargetComponent()

        // Assemble the guitar
        entity.addChild(fretboardEntity)
        entity.addChild(bodyEntity)
        entity.addChild(tapAreaEntity)

        // Position and orient the guitar
        entity.position = [
            config.guitarXPosition,
            config.guitarYPosition,
            config.guitarZPosition
        ]
        entity.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
    }

    func handleTap() {
        tapAreaEntity.model?.materials = [SimpleMaterial(color: .red, isMetallic: true)]

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            tapAreaEntity.model?.materials = [Self.materials.tapArea]
        }
    }
}

struct VirtualGuitarPreview: View {
    let config: VirtualGuitarConfig

    init(config: VirtualGuitarConfig = VirtualGuitarConfig()) {
        self.config = config
    }

    var body: some View {
        RealityView { content in
            let guitarManager = VirtualGuitarEntityManager(config: config)
            let guitarEntity = guitarManager.setupGuitarEntity()
            content.add(guitarEntity)
        }
    }
}

// Xcode Preview
#Preview {
    VirtualGuitarPreview()
}

// Alternative preview with custom configuration
#Preview("Custom Guitar") {
    VirtualGuitarPreview(config: VirtualGuitarConfig(
        fretboardLength: 0.25,
        bodyLength: 0.35,
        tapAreaXOffset: 0.15
    ))
}
