//
//  ConnectivityManager.swift
//  tesWatch
//
//  Created by Yimei Winata on 26/06/26.
//

import WatchConnectivity
import WatchKit
import Combine
import AVFoundation

final class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    static let shared = ConnectivityManager()
    @Published var receivedUserInfo: String = "Menunggu data..."
    // Create a speech synthesizer.
    private let synthesizer = AVSpeechSynthesizer()
    
    
    override init() {
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        warmUpSynthesizer()
    }
    func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String : Any] = [:]
    ) {
        print("==========")
        print("Receive:", Date())
        if let value = userInfo["seconds"] {
            print("Type: \(type(of: value)), Value: \(value)")
        }
        
        guard let type = userInfo["type"] as? String else { return }
        
        switch type {
        case "start":
            start(userInfo)
        case "haptics1":
            hapticLoop(userInfo)
        case "haptics2":
            hapticLoop(userInfo)
        default :
            break
        }
        
        
    }
    
    private func speak(_ text: String) {
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
    
    private func warmUpSynthesizer() {
        let warmupUtterance = AVSpeechUtterance(string: "hi")
        warmupUtterance.volume = 0.0  // biar ga kedengeran user
        synthesizer.speak(warmupUtterance)
    }
    
    private func hapticLoop(_ userInfo: [String: Any]){
        guard let loops = userInfo["loops"] as? Int else { return }
        
        for i in 1...loops{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    
    private func start(_ userInfo: [String: Any]) {
        WKInterfaceDevice.current().play(.notification)
        
        DispatchQueue.main.async {
            if let dataText = userInfo["seconds"] as? String {
                self.receivedUserInfo = dataText
                self.speak("Aku alarm")
            }
        }
    }
    
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated")
    }
    
}
