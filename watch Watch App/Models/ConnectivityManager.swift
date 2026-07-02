//
//  ConnectivityManager.swift
//  CH4
//
//  Created by Yimei Winata on 02/07/26.
//

import Foundation
import WatchConnectivity
import WatchKit
import Combine
import AVFoundation

class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var receivedUserInfo: String = "0"
    static let shared = ConnectivityManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        if WCSession.isSupported(){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        WKInterfaceDevice.current().play(.notification)
        
        print("Received:", userInfo)
        
        DispatchQueue.main.async {
            if let dataText = userInfo["seconds"] as? String {
                self.receivedUserInfo = dataText
                self.speak("Aku alarm")
            }
        }
    }
    
    func speak(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "id-ID")
        
        synthesizer.speak(utterance)
    }
    
    func warmUpSynthesizer() {
        let warmupUtterance = AVSpeechUtterance(string: "null")
        warmupUtterance.volume = 0.0
        synthesizer.speak(warmupUtterance)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("Connecting From iOS Success")
    }
    
}


