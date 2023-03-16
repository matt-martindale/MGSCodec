//
//  CodecViewModel.swift
//  MGSCodec
//
//  Created by Matthew Martindale on 12/1/21.
//

import Foundation

class CodecViewModel {
    var snakeCodecCalls = CodecCallArray(snakeCodecCallsArray)
    var zeroCodecCalls = CodecCallArray(zeroCodecCallsArray)
    var evaCodecCalls = CodecCallArray(evaCodecCallsArray)
    var ocelotCodecCalls = CodecCallArray(ocelotCodecCallsArray)
    var otaconCodecCalls = CodecCallArray(otaconCodecCallsArray)
    var colonelCodecCalls = CodecCallArray(colonelCodecCallsArray)
    var theBossCodecCalls = CodecCallArray(theBossCodecCallsArray)
    var paramedicCodecCalls = CodecCallArray(paramedicCodecCallsArray)
    var sigintCodecCalls = CodecCallArray(sigintCodecCallsArray)
    var crownAccumulator = 0.0
    var crownValue = Box(value: 140.85)
    let decimalFormatter: NumberFormatter = {
       let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.minimumFractionDigits = 2
        decimalFormatter.maximumFractionDigits = 2
        return decimalFormatter
    }()
    
    func handleCrownDidRotate() {
        if crownValue.value < 140.00 {
            crownValue.value = 142.99
        }
        if crownValue.value > 142.99 {
            crownValue.value = 140.00
        }
        
        if crownAccumulator > 0.06 {
            crownValue.value += 0.01
            crownAccumulator = 0.0
        } else if crownAccumulator < -0.06 {
            crownValue.value -= 0.01
            crownAccumulator = 0.0
        }
    }

    func getCodecImage(_ codecCall: CodecCall) -> String {
        if codecCall.category == .character {
            return codecCall.character.rawValue
        } else if codecCall.category == .track {
            return "track"
        } else {
            return "none"
        }
    }

    func fetchCodecDetails(frequency: Double) -> CodecCall {
        switch frequency {
        case 140.85:
            return getCallFor(category: .character, character: .zero)
        case 140.87:
            return getCallFor(category: .character, character: .colonel)
        case 141.12:
            return getCallFor(category: .character, character: .otacon)
        case 141.41:
            return getCallFor(category: .character, character: .sigint)
        case 141.80:
            return getCallFor(category: .character, character: .theBoss)
        case 142.41:
            return getCallFor(category: .track, character: nil, song: .mgs3Theme)
        case 142.42:
            return getCallFor(category: .track, character: nil, song: .wayToFall)
        case 142.43:
            return getCallFor(category: .track, character: nil, song: .snakeEater)
        case 142.52:
            return getCallFor(category: .character, character: .eva)
        case 142.73:
            return getCallFor(category: .character, character: .paramedic)
        case 142.75:
            return getCallFor(category: .character, character: .ocelot)
        default:
            return getCallFor(category: .character, character: MGSCharacter.none)
        }
    }

    func getCallFor(category: AudioCategory, character: MGSCharacter?, song: Song? = nil) -> CodecCall {
        let defaultCodec = CodecCall(voiceFile: "doorbuzz", voiceText: "- NO RESPONSE -", category: .character, character: .none)
        switch category {
        case .track:
            switch song {
            case .mgs3Theme:
                return CodecCall(voiceFile: "MGS3-Theme", voiceText: "Metal Gear Solid 3 - Main Theme", category: .track, character: .none)
            case .wayToFall:
                return CodecCall(voiceFile: "wayToFall", voiceText: "Starsailor - Way to Fall", category: .track, character: .none)
            case .snakeEater:
                return CodecCall(voiceFile: "snakeEater", voiceText: "Metal Gear Solid 3 - Snake Eater", category: .track, character: .none)
            default:
                return defaultCodec
            }
        case .character:
            guard let character = character else {
                return defaultCodec
            }
            switch character {
            case .snake:
                return snakeCodecCalls.getRandomCodecCall()
            case .zero:
                return zeroCodecCalls.getRandomCodecCall()
            case .eva:
                return evaCodecCalls.getRandomCodecCall()
            case .ocelot:
                return ocelotCodecCalls.getRandomCodecCall()
            case .otacon:
                return otaconCodecCalls.getRandomCodecCall()
            case .colonel:
                return colonelCodecCalls.getRandomCodecCall()
            case .theBoss:
                return theBossCodecCalls.getRandomCodecCall()
            case .paramedic:
                return paramedicCodecCalls.getRandomCodecCall()
            case .sigint:
                return sigintCodecCalls.getRandomCodecCall()
            case .none:
                return defaultCodec
            }
        }
    }

}
