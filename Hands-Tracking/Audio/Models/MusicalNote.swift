// Sources/Audio/Models/MusicalNote.swift

import Foundation

struct MusicalNote: Equatable {
    let pitch: Int
    let name: String
    
    static let C = MusicalNote(pitch: 0, name: "C")
    static let CSharp = MusicalNote(pitch: 1, name: "C#")
    static let D = MusicalNote(pitch: 2, name: "D")
    static let DSharp = MusicalNote(pitch: 3, name: "D#")
    static let E = MusicalNote(pitch: 4, name: "E")
    static let F = MusicalNote(pitch: 5, name: "F")
    static let FSharp = MusicalNote(pitch: 6, name: "F#")
    static let G = MusicalNote(pitch: 7, name: "G")
    static let GSharp = MusicalNote(pitch: 8, name: "G#")
    static let A = MusicalNote(pitch: 9, name: "A")
    static let ASharp = MusicalNote(pitch: 10, name: "A#")
    static let B = MusicalNote(pitch: 11, name: "B")
}
