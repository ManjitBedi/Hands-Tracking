// Sources/Audio/Services/AudioEngine.swift

import AVFoundation

class AudioEngine: AudioEngineProtocol {
    private var audioEngine: AVAudioEngine
    private var sampler: AVAudioUnitSampler
    private var mixer: AVAudioMixerNode
    private var reverbNode: AVAudioUnitReverb
    private(set) var isPlaying: Bool = false

    init() {
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        mixer = AVAudioMixerNode()
        reverbNode = AVAudioUnitReverb()

        setupAudioChain()
        setupDefaultInstrument()
    }

    private func setupAudioChain() {
        // Add nodes to engine
        audioEngine.attach(sampler)
        audioEngine.attach(mixer)
        audioEngine.attach(reverbNode)

        // Connect nodes
        audioEngine.connect(sampler, to: mixer, format: nil)
        audioEngine.connect(mixer, to: reverbNode, format: nil)
        audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: nil)

        // Set default reverb preset
        reverbNode.loadFactoryPreset(.largeHall2)
        reverbNode.wetDryMix = 20

        // Set volumes
        mixer.outputVolume = 0.8
        sampler.volume = 1.0
    }

    private func setupDefaultInstrument() {
        // Use program change to select acoustic guitar (program 25)
        sampler.sendProgramChange(25, bankMSB: 0, bankLSB: 0, onChannel: 0)
    }

    func start() throws {
        print("Starting audio engine...")
        if !audioEngine.isRunning {
            try audioEngine.start()
            print("Audio engine started successfully")
        }
    }

    func stop() {
        audioEngine.stop()
    }

    func playNote(_ note: MusicalNote, octave: Int, velocity: Float) {
        let midiNoteNumber = UInt8((octave + 1) * 12 + note.pitch)
        print("Playing MIDI note: \(midiNoteNumber), velocity: \(UInt8(velocity * 127))")
        sampler.startNote(midiNoteNumber, withVelocity: UInt8(velocity * 127), onChannel: 0)
        isPlaying = true

        // Stop the note after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sampler.stopNote(midiNoteNumber, onChannel: 0)
            self.isPlaying = false
        }
    }

    func playChord(_ notes: [(note: MusicalNote, octave: Int)], velocity: Float) {
        isPlaying = true
        for (note, octave) in notes {
            let midiNoteNumber = UInt8((octave + 1) * 12 + note.pitch)
            print("Playing MIDI note: \(midiNoteNumber), velocity: \(UInt8(velocity * 127))")
            sampler.startNote(midiNoteNumber, withVelocity: UInt8(velocity * 127), onChannel: 0)

            // Stop the note after 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sampler.stopNote(midiNoteNumber, onChannel: 0)
                self.isPlaying = false
            }
        }
    }

    func stopNote(_ note: MusicalNote, octave: Int) {
        let midiNoteNumber = UInt8((octave + 1) * 12 + note.pitch)
        sampler.stopNote(midiNoteNumber, onChannel: 0)
        isPlaying = false
    }

    func setVolume(_ volume: Float) {
        mixer.outputVolume = volume
    }

    func setReverb(_ amount: Float) {
        reverbNode.wetDryMix = amount
    }
}
