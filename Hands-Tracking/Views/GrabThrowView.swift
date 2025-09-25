//
//  GrabThrowView.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-09-24.
//

import SwiftUI
import RealityKit
import ARKit
import simd

struct GrabThrowView: View {
    @State private var anchor = AnchorEntity()
    @State private var sphere: ModelEntity?
    @State private var rightHandAnchor: AnchorEntity?
    @State private var leftHandAnchor: AnchorEntity?
    @State private var lastPosition: SIMD3<Float>?
    @State private var lastTime: Date?
    @State private var lastVelocity: SIMD3<Float>? = nil
    @State private var isAttachedToHand = true
    @State private var originalOffset: SIMD3<Float> = [0, 0.1, 0]
    @State private var leftHandPinched = false
    @State private var trailEntities: [Entity] = []

    var body: some View {
        VStack {
            RealityView { content in
                // Create hand tracking anchors
                let rightHand = AnchorEntity(.hand(.right, location: .palm))
                let leftHand = AnchorEntity(.hand(.left, location: .palm))
                rightHandAnchor = rightHand
                leftHandAnchor = leftHand

                content.add(rightHand)
                content.add(leftHand)
                content.add(anchor)

                // Create initial sphere on right hand
                createNewSphere()

            } update: { content in
                // Remove state modification from here
            }
            .gesture(
                // Detect throwing gesture
                DragGesture()
                    .targetedToAnyEntity()
                    .onChanged { value in
                        guard isAttachedToHand else { return }

                        let handPosition = value.convert(value.location3D, from: .local, to: .scene)
                        let now = Date()

                        // Track hand velocity while attached
                        if let lastPos = lastPosition, let lastT = lastTime {
                            let dt = Float(now.timeIntervalSince(lastT))
                            if dt > 0 {
                                let velocity = (handPosition - lastPos) / dt
                                lastVelocity = velocity

                                // Check if gesture is fast enough to trigger release
                                let speed = length(velocity)
                                if speed > 2.5 { // Threshold for release
                                    releaseFromHand()
                                }
                            }
                        }

                        lastPosition = handPosition
                        lastTime = now
                    }
                    .onEnded { _ in
                        lastPosition = nil
                        lastTime = nil
                    }
            )

            Spacer()

            // Manual controls
            HStack(spacing: 20) {
                Button("Arm New Sphere") {
                    createNewSphere()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Clear Trails") {
                    clearAllTrails()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    private func createNewSphere() {
        guard let rightHandAnchor = rightHandAnchor else { return }

        // Remove existing sphere if any
        sphere?.removeFromParent()

        // Create new sphere
        let newSphere = ModelEntity(
            mesh: .generateSphere(radius: 0.07),
            materials: [SimpleMaterial(color: .green, isMetallic: false)]
        )

        newSphere.position = originalOffset
        newSphere.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.07)]))
        newSphere.components.set(InputTargetComponent())

        // Start in kinematic mode (attached to hand)
        newSphere.components.set(PhysicsBodyComponent(
            massProperties: .init(mass: 1),
            material: PhysicsMaterialResource.generate(
                staticFriction: 0.8,
                dynamicFriction: 0.6,
                restitution: 0.1
            ),
            mode: .kinematic
        ))

        rightHandAnchor.addChild(newSphere)
        self.sphere = newSphere
        self.isAttachedToHand = true

        // Reset tracking state
        lastPosition = nil
        lastTime = nil
        lastVelocity = nil
    }

    private func releaseFromHand() {
        guard let sphere = sphere, isAttachedToHand else { return }

        isAttachedToHand = false

        // Change color to indicate release
        sphere.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]

        // Get current world position before removing from hand
        let worldPosition = sphere.convert(position: sphere.position, to: nil)

        // Remove from hand anchor and add to world anchor
        sphere.removeFromParent()
        anchor.addChild(sphere)
        sphere.position = worldPosition

        // Start particle trail effect
        startTrailEffect(for: sphere)

        // Apply physics for throwing with sticky material
        sphere.components.set(
            PhysicsBodyComponent(
                massProperties: .init(mass: 1.0),
                material: PhysicsMaterialResource.generate(
                    staticFriction: 1.0,  // High friction for sticking
                    dynamicFriction: 0.9,
                    restitution: 0.01     // Very low bounce
                ),
                mode: .dynamic
            )
        )

        // Enable collision with real world surfaces
        sphere.components.set(CollisionComponent(
            shapes: [.generateSphere(radius: 0.07)],
            mode: .default,
            filter: .default
        ))

        // Apply throwing velocity
        if let velocity = lastVelocity {
            let throwVelocity = velocity * 1.5
            sphere.components.set(PhysicsMotionComponent(linearVelocity: throwVelocity))
        }

        // Stop trail effect after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopTrailEffect()
        }

        // Clean up
        lastVelocity = nil
    }

    private func startTrailEffect(for sphere: Entity) {
        // Create a custom trail using multiple small spheres
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            guard let currentSphere = self.sphere,
                  currentSphere == sphere,
                  !self.isAttachedToHand else {
                timer.invalidate()
                return
            }

            // Create trail particle - much smaller and more transparent
            let trailParticle = ModelEntity(
                mesh: .generateSphere(radius: 0.005), // Very small - 5mm
                materials: [SimpleMaterial(color: UIColor.orange.withAlphaComponent(0.4), isMetallic: false)]
            )

            trailParticle.position = sphere.position
            trailParticle.transform.scale = [0.5, 0.5, 0.5] // Make even smaller
            self.anchor.addChild(trailParticle)
            self.trailEntities.append(trailParticle)

            // Fade out trail particle quickly
            self.fadeOutTrailParticle(trailParticle)
        }
    }

    private func fadeOutTrailParticle(_ particle: Entity) {
        // Make particles much smaller and more transparent for trail effect
        if let model = particle as? ModelEntity {
            // Start very small and transparent
            model.transform.scale = [0.3, 0.3, 0.3]
            let material = SimpleMaterial(color: UIColor.orange.withAlphaComponent(0.3), isMetallic: false)
            model.model?.materials = [material]
        }

        // Fade to red
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let model = particle as? ModelEntity {
                let material = SimpleMaterial(color: UIColor.red.withAlphaComponent(0.2), isMetallic: false)
                model.model?.materials = [material]
                model.transform.scale = [0.2, 0.2, 0.2]
            }
        }

        // Remove quickly for trail effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            particle.removeFromParent()
            if let index = self.trailEntities.firstIndex(where: { $0 == particle }) {
                self.trailEntities.remove(at: index)
            }
        }
    }

    private func stopTrailEffect() {
        // Trail will naturally stop when sphere stops moving due to timer check
    }

    private func clearAllTrails() {
        for trail in trailEntities {
            trail.removeFromParent()
        }
        trailEntities.removeAll()
    }
}
