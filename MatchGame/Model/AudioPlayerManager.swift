//
//  AudioPlayerManager.swift
//  MatchGame
//
//  Created by Mykhailo Dovhyi on 19.11.2024.
//

import AVFoundation

final class AudioPlayerManager:NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    var canPlay:Bool = true
    var endedPlayingAction:(()->())?
    deinit {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    
    var type:BundleAudio? = .bonus
    convenience init(type:BundleAudio) {
        self.init(audioName: type.rawValue, isRepeated: type.repeated, valuem: type.valuem)
    }
    
    init(audioName:String, isRepeated:Bool, valuem:Float) {
        super.init()
        self.type = .init(rawValue: audioName)
        if let soundUrl = Bundle.main.url(forResource: audioName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                if isRepeated {
                    audioPlayer?.numberOfLoops =  -1
                }
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                self.updateValuem()
            } catch {
#if DEBUG
                print("Error loading audio file: \(error.localizedDescription)")
#endif
            }
        }
    }

    func play(completion:(()->())? = nil) {
        if canPlay {
            self.endedPlayingAction = completion
            self.audioPlayer?.play()
        }
    }
    
    func stop() {
        self.audioPlayer?.stop()
    }
    
    func updateValuem() {
        DispatchQueue(label: "db", qos: .userInitiated).async {
            let data = DB.db.sound.valuems[self.type?.soundType ?? .background] ?? 0
            DispatchQueue.main.async {
                self.audioPlayer?.volume = Float(data)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        endedPlayingAction?()
        endedPlayingAction = nil
    }
}

extension AudioPlayerManager {
    enum BundleAudio:String, CaseIterable {
        case coin, bonus, gameScs, gameLose, gameBackground1, lvlBackground1, timeover, lvlSelected, panStart, error, menu
        var repeated:Bool {
            rawValue.contains("Background")
        }
        var valuem:Float {
            if repeated {
                return 1
            } else {
                return 0.2
            }
        }
        
        var soundType:DB.DataBase.SoundParameters.Sound {
            switch self {
            case .coin, .bonus, .gameScs, .gameLose:
                    .click
            case .gameBackground1, .lvlBackground1:
                    .background
            case .timeover, .lvlSelected, .menu, .error, .panStart:
                    .menu
            }
        }
        static var lvlBackground:[BundleAudio] {
            allCases.filter({$0.rawValue.contains("levelBackground")})
        }
        static var gameBackground:[BundleAudio] {
            allCases.filter({$0.rawValue.contains("gameBackground")})
        }
    }
}
