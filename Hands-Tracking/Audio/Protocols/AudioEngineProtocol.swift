// Sources/Audio/Protocols/AudioEngineProtocol.swift

import Foundation
import AVFoundation

protocol AudioEngineProtocol {
    func start() throws
    func stop()
    func playNote(_ note: MusicalNote, octave: Int, velocity: Float)
    func stopNote(_ note: MusicalNote, octave: Int)
    func setVolume(_ volume: Float)
    func setReverb(_ amount: Float)
}
