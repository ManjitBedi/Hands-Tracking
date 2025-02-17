//
//  VirtualGuitarEntityManager.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import RealityKit

class VirtualGuitarEntityManager {
    private(set) var guitarEntity: ModelEntity
    let virtualGuitar: VirtualGuitar

    init(dimensions: GuitarDimensions = GuitarDimensions()) {
        self.virtualGuitar = VirtualGuitar(dimensions: dimensions)
        self.guitarEntity = virtualGuitar.entity

        // Set default position and orientation
        guitarEntity.position = [0, 0.8, -0.5]
        guitarEntity.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
    }

    func setupGuitarEntity() -> ModelEntity {
        return guitarEntity
    }

    func handleTap() {
        virtualGuitar.handleTap()
    }

    func updatePosition(x: Float, y: Float, z: Float) {
        guitarEntity.position = [x, y, z]
    }

    func updateOrientation(angle: Float, axis: SIMD3<Float>) {
        guitarEntity.orientation = simd_quatf(angle: angle, axis: axis)
    }
}
