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
    
    // MARK: - Properties
    let codecViewModel = CodecViewModel()
    var audioPlayer: AVAudioPlayer?
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
        codecViewModel.crownValue.bind { [weak self] crownValue in
            if let value = self?.codecViewModel.decimalFormatter.string(from: NSNumber(value: crownValue)) {
                self?.textLabel.setText(String(value))
                self?.myValue = crownValue
            }
        }
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
    
    // MARK: - Methods
    func handleCodecTapped() {
        count = 0
        let font = UIFont(name:"TickingTimebombBB", size: 18) ?? UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        let attrStr = NSAttributedString(string: "\n--CALLING--", attributes: [NSAttributedString.Key.font: font])
        textLabel.setAttributedText(attrStr)
        playCodecFile("codeccall")
    }
    
    func playCodecFile(_ file: String) {
        if let noResponseURL = Bundle.main.url(forResource: "doorbuzz", withExtension: "mp3") {
            let url = Bundle.main.url(forResource: file, withExtension: "mp3") ?? noResponseURL
            try? audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            audioPlayer?.delegate = self
        }
    }
    
    func handleAudioClip(frequency: Double) {
        count += 1
        let codecCall = codecViewModel.fetchCodecDetails(frequency: frequency)
        let font = UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.medium)
        let attrStr = NSAttributedString(string: codecCall.voiceText, attributes: [NSAttributedString.Key.font: font])
        textLabel.setAttributedText(attrStr)
        codecImage.setImageNamed(codecViewModel.getCodecImage(codecCall))
        if codecCall.category == .track {
            playTrackFile(codecCall.voiceFile)
        }
        playCodecFile(codecCall.voiceFile)
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
        
        guard let url = Bundle.main.url(forResource: file, withExtension: "mp3") else {
            fatalError("Unable to locate track file")
        }
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
        let frequency = String(format: "%.2f", myValue)
        textLabel.setText(String(frequency))
    }
    
    // MARK: - AudioPlayer delegate methods
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        codecViewModel.crownAccumulator += rotationalDelta
        
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            crownSequencer?.resignFocus()
            return
        } else {
            codecViewModel.handleCrownDidRotate()
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
            let frequency = String(format: "%.2f", myValue)
            textLabel.setText(String(frequency))
        }
    }
    
}
