//
//  VirtualGuitarEntityManager.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-16.
//

import RealityKit

class VirtualGuitarEntityManager {
    var guitarEntity: ModelEntity?
    let virtualGuitar: VirtualGuitar

    init(config: VirtualGuitarConfig = VirtualGuitarConfig()) {
        self.virtualGuitar = VirtualGuitar(config: config)
        self.guitarEntity = virtualGuitar.entity
    }

    func setupGuitarEntity() -> ModelEntity {
        return virtualGuitar.entity
    }

    func handleTap() {
        virtualGuitar.handleTap()
    }
}
