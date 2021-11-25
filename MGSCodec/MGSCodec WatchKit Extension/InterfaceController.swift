//
//  InterfaceController.swift
//  MGSCodec WatchKit Extension
//
//  Created by Matthew Martindale on 11/24/21.
//

import WatchKit
import AVFoundation


class InterfaceController: WKInterfaceController, WKCrownDelegate, AVAudioPlayerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var codecImage: WKInterfaceImage!
    @IBOutlet weak var textLabel: WKInterfaceLabel!
    @IBOutlet weak var frequenciesLabel: WKInterfaceLabel!
    
    // MARK: - Properties
    var crownAccumulator = 0.0
    var audioPlayer: AVAudioPlayer?
    var semaphore = DispatchSemaphore(value: 1)
    var count = 0
    var myValue: Double = 140.85 {
        didSet {
            myValue = round(myValue * 100) / 100.0
            let frequency = String(format: "%.2f", myValue)
            textLabel.setText(String(frequency))
            if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
    }
    
    // MARK: - Lifecycle methods
    override func awake(withContext context: Any?) {
        crownSequencer.delegate = self
    }

    override func willActivate() {
        crownSequencer.focus()
    }
    
    // MARK: - IBActions
    @IBAction func codecTapped(_ sender: Any) {
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            resetCodec(audioPlayer)
        } else {
            handleCodecTapped()
        }
    }
    
    @IBAction func frequencyTapped(_ sender: Any) {
        presentController(withName: "Frequency", context: nil)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        crownAccumulator += rotationalDelta
        
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            crownSequencer?.resignFocus()
            return
        } else {
            if myValue < 140.00 {
                myValue = 142.99
            }
            if myValue > 142.99 {
                myValue = 140.00
            }
            
            if crownAccumulator > 0.06 {
                myValue += 0.01
                crownAccumulator = 0.0
            } else if crownAccumulator < -0.06 {
                myValue -= 0.01
                crownAccumulator = 0.0
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        defer {
            crownSequencer.focus()
        }
        if count == 0 {
            count += 1
            let font = UIFont(name:"TickingTimebombBB", size: 18) ?? UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
            let attrStr = NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: font])
            textLabel.setAttributedText(attrStr)
            playCodecFile("codecopen")
            return
        } else if count == 1 {
            handleAudioClip(frequency: myValue)
        } else {
            codecImage.setImageNamed("none")
            textLabel.setText(String(myValue))
        }
    }
    
    func handleCodecTapped() {
        count = 0
        let font = UIFont(name:"TickingTimebombBB", size: 18) ?? UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        let attrStr = NSAttributedString(string: "\n--CALLING--", attributes: [NSAttributedString.Key.font: font])
        textLabel.setAttributedText(attrStr)
        playCodecFile("codeccall")
    }
    
    func handleAudioClip(frequency: Double) {
        count += 1
        let codecCall = fetchCodecDetails(frequency: frequency)
        let font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.medium)
        let attrStr = NSAttributedString(string: codecCall.voiceText, attributes: [NSAttributedString.Key.font: font])
        textLabel.setAttributedText(attrStr)
        setCodecImage(codecCall)
        if codecCall.category == .track {
            playTrackFile(codecCall.voiceFile)
        }
        playCodecFile(codecCall.voiceFile)
    }
    
    func setCodecImage(_ codecCall: CodecCall) {
        if codecCall.category == .character {
            codecImage.setImageNamed(codecCall.character.rawValue)
        } else if codecCall.category == .track {
            codecImage.setImageNamed("track")
        } else {
            codecImage.setImageNamed("none")
        }
    }
    
    func playCodecFile(_ file: String) {
        if let noResponseURL = Bundle.main.url(forResource: "doorbuzz", withExtension: "mp3") {
            let url = Bundle.main.url(forResource: file, withExtension: "mp3") ?? noResponseURL
            try? audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            audioPlayer?.delegate = self
        }
    }
    
    func playTrackFile(_ file: String) {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: .default,
                                    policy: .longFormAudio,
                                    options: [])
        } catch let error {
            fatalError("Unable to set up the audio session: \(error.localizedDescription)")
        }
        
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else { return }
        try? audioPlayer = AVAudioPlayer(contentsOf: url)
        
        session.activate(options: []) { success, error in
            guard error == nil else {
                return
            }
        }
        audioPlayer?.play()
    }
    
    func resetCodec(_ audioPlayer: AVAudioPlayer) {
        audioPlayer.stop()
        crownSequencer.focus()
        codecImage.setImageNamed("none")
        textLabel.setText(String(myValue))
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
                return CodecCall(voiceFile: "wayToFall", voiceText: "Starsailor - Way to Fall", category: .track, character: .none)
            }
        case .character:
            guard let character = character else {
                return defaultCodec
            }
            switch character {
            case .snake:
                return snakeCodecCalls.randomElement() ?? defaultCodec
            case .zero:
                return zeroCodecCalls.randomElement() ?? defaultCodec
            case .eva:
                return evaCodecCalls.randomElement() ?? defaultCodec
            case .ocelot:
                return ocelotCodecCalls.randomElement() ?? defaultCodec
            case .otacon:
                return otaconCodecCalls.randomElement() ?? defaultCodec
            case .colonel:
                return colonelCodecCalls.randomElement() ?? defaultCodec
            case .theBoss:
                return theBossCodecCalls.randomElement() ?? defaultCodec
            case .paramedic:
                return paramedicCodecCalls.randomElement() ?? defaultCodec
            case .sigint:
                return sigintCodecCalls.randomElement() ?? defaultCodec
            case .none:
                return defaultCodec
            }
        }
    }
    
}
