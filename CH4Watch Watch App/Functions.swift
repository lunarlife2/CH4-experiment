//
//  Functions.swift
//  CH4
//
//  Created by Yimei Winata on 01/07/26.
//
import WatchConnectivity
import WatchKit
import Combine
import AVFoundation
import Foundation

public func speak(_ text: String, synthesizer: AVSpeechSynthesizer) {
    // Kalau lagi ngomong, stop dulu biar ga numpuk
    if synthesizer.isSpeaking {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    let utterance = AVSpeechUtterance(string: text)
    utterance.rate = 0.5
    utterance.pitchMultiplier = 1.0
    utterance.volume = 1.0
    utterance.voice = AVSpeechSynthesisVoice(language: "id-ID") // bahasa Indonesia
    
    synthesizer.speak(utterance)
}

public func warmUpSynthesizer(synthesizer: AVSpeechSynthesizer) {
    let warmupUtterance = AVSpeechUtterance(string: "hi")
    warmupUtterance.volume = 0.0  // biar ga kedengeran user
    synthesizer.speak(warmupUtterance)
}

public func hapticLoop(loops: Int){
    var i = 0
    repeat {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
            WKInterfaceDevice.current().play(.notification)
        }
        i = i + 1
    } while (i < loops)
}

public func startHaptic (text: String, synthesizer: AVSpeechSynthesizer) {
    WKInterfaceDevice.current().play(.notification)
    
    DispatchQueue.main.async {
        speak(text, synthesizer: synthesizer)
    }
}

