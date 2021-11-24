//
//  CodecCall.swift
//  whatever
//
//  Created by Matthew Martindale on 11/17/21.
//

import Foundation

struct CodecCall {
    let voiceFile: String
    let voiceText: String
    let category: AudioCategory
    let character: MGSCharacter
}

enum AudioCategory {
    case track, character
}

enum MGSCharacter: String {
    case snake, zero, eva, ocelot, otacon, colonel, theBoss, paramedic, sigint, none
}

enum Song {
    case wayToFall, mgs3Theme, snakeEater
}
