//
//  GuitarDimensions.swift
//  Hands-Tracking
//
//  Created by Manjit Bedi on 2025-02-17.
//

import Foundation

struct GuitarDimensions {
    // Base dimensions
    var totalLength: Float = 0.5  // Total length of the guitar

    // Relative dimensions
    struct RelativeDimensions {
        // Fretboard takes up 40% of total length
        var fretboardLengthRatio: Float = 0.4
        var fretboardHeightRatio: Float = 0.04  // Relative to total length
        var fretboardWidthRatio: Float = 0.2    // Relative to total length

        // Body takes up 60% of total length
        var bodyLengthRatio: Float = 0.6
        var bodyHeightRatio: Float = 0.1     // Relative to total length
        var bodyWidthRatio: Float = 0.4      // Relative to total length

        // String area on fretboard
        var stringAreaLengthRatio: Float = 0.9  // Relative to fretboard length
        var stringAreaHeightRatio: Float = 0.02 // Relative to total length
        var stringAreaWidthRatio: Float = 0.8   // Relative to fretboard width

        // Strum area on body
        var strumAreaLengthRatio: Float = 0.2   // Relative to body length
        var strumAreaHeightRatio: Float = 0.06  // Relative to total length
        var strumAreaWidthRatio: Float = 0.3    // Relative to body width
    }

    var ratios = RelativeDimensions()

    // Position configuration
    enum StrumAreaAlignment {
        case center
        case rightEdge
    }

    var strumAreaAlignment: StrumAreaAlignment = .center

    // Computed actual dimensions
    var fretboardDimensions: SIMD3<Float> {
        [
            totalLength * ratios.fretboardLengthRatio,
            totalLength * ratios.fretboardHeightRatio,
            totalLength * ratios.fretboardWidthRatio
        ]
    }

    var bodyDimensions: SIMD3<Float> {
        [
            totalLength * ratios.bodyLengthRatio,
            totalLength * ratios.bodyHeightRatio,
            totalLength * ratios.bodyWidthRatio
        ]
    }

    var stringAreaDimensions: SIMD3<Float> {
        [
            fretboardDimensions.x * ratios.stringAreaLengthRatio,
            totalLength * ratios.stringAreaHeightRatio,
            fretboardDimensions.z * ratios.stringAreaWidthRatio
        ]
    }

    var strumAreaDimensions: SIMD3<Float> {
        [
            bodyDimensions.x * ratios.strumAreaLengthRatio,
            totalLength * ratios.strumAreaHeightRatio,
            bodyDimensions.z * ratios.strumAreaWidthRatio
        ]
    }
}
