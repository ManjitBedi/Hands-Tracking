// Sources/Audio/Models/Note.swift

struct Note {
    let pitch: Int
    let octave: Int
    
    static let E = Note(pitch: 4, octave: 4)
    static let A = Note(pitch: 9, octave: 4)
    static let D = Note(pitch: 2, octave: 4)
    static let G = Note(pitch: 7, octave: 4)
    static let B = Note(pitch: 11, octave: 4)
    
    func raised(byHalfSteps steps: Int) -> Note {
        let newPitch = pitch + steps
        let pitchInOctave = newPitch % 12
        let octaveChange = newPitch / 12
        
        return Note(
            pitch: pitchInOctave,
            octave: octave + octaveChange
        )
    }
}
