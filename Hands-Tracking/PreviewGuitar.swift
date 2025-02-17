import RealityKit
import SwiftUI

class PreviewGuitarManager {
    let config: VirtualGuitarConfig

    init(config: VirtualGuitarConfig = VirtualGuitarConfig()) {
        self.config = config
    }
}

struct HackedGuitarPreview: View {
    @State private var guitarManager: PreviewGuitarManager

    init(config: VirtualGuitarConfig = VirtualGuitarConfig()) {
        _guitarManager = State(initialValue: PreviewGuitarManager(config: config))
    }

    var body: some View {
        RealityView { content in
            // Fretboard
            let fretboardEntity = ModelEntity(
                mesh: .generateBox(size: [
                    guitarManager.config.fretboardLength,
                    guitarManager.config.fretboardHeight,
                    guitarManager.config.fretboardWidth
                ]),
                materials: [SimpleMaterial(color: .brown, isMetallic: false)]
            )
            fretboardEntity.position = [-0.15, 0.02, 0]

            // Body
            let bodyEntity = ModelEntity(
                mesh: .generateBox(size: [
                    guitarManager.config.bodyLength,
                    guitarManager.config.bodyHeight,
                    guitarManager.config.bodyWidth
                ]),
                materials: [SimpleMaterial(color: .brown, isMetallic: false)]
            )
            bodyEntity.position = [0.15, 0, 0]

            // Strum Area
            let strumAreaEntity = ModelEntity(
                mesh: .generateBox(size: [
                    guitarManager.config.tapAreaLength,
                    guitarManager.config.tapAreaHeight,
                    guitarManager.config.tapAreaWidth
                ]),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            strumAreaEntity.position = [0.25, 0.03, 0]

            // String Area
            let stringAreaEntity = ModelEntity(
                mesh: .generateBox(size: [
                    guitarManager.config.fretboardLength,
                    guitarManager.config.fretboardHeight,
                    guitarManager.config.fretboardWidth
                ]),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            stringAreaEntity.position = [-0.25, 0.03, 0]

            // Create a parent entity to group all parts
            let guitarEntity = ModelEntity()
            guitarEntity.addChild(fretboardEntity)
            guitarEntity.addChild(bodyEntity)
            guitarEntity.addChild(strumAreaEntity)
            guitarEntity.addChild(stringAreaEntity)

            // Rotate the entire guitar entity
            guitarEntity.orientation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])

            content.add(guitarEntity)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    HackedGuitarPreview()
}
