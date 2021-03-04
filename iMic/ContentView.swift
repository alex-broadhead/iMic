//
//  ContentView.swift
//  iMic
//
//  Created by Alex Broadhead on 3/3/21.
//

import SwiftUI
import AVKit
import MediaPlayer

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            slider?.value = volume
        }
    }
}

struct ContentView: View {
    @State var audioHandler: AudioHandler = AudioHandler()
    @State var showPlay: Bool = true
    
    var body: some View {
        VStack {
            // MAB - These are super hacky, but work to handle notifications!
            Text("")
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("Will resign active!")
                    audioHandler.returnSystemVolume()
                }
            
            Text("")
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("Did become active!")
                    audioHandler.setSystemVolumeToMax()
                }
            
            Text("iMic").font(.system(size: 45)).font(.largeTitle)
            
            HStack {
                // Place play and pause on top of each other, and toggle them
                if showPlay {
                    Button(action: {
                        audioHandler.play()
                        showPlay = false
                    }) {
                        Image(systemName: "play.circle.fill").resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                
                if !showPlay {
                    Button(action: {
                        audioHandler.pause()
                        showPlay = true
                    }) {
                        Image(systemName: "pause.circle.fill").resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
        
        .onAppear {
            print("Did appear!")
            audioHandler.enableBluetoothOutput()    // send output to Bluetooth, if available
            audioHandler.loadAudio()                // load our file
            audioHandler.setSystemVolumeToMax()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class AudioHandler: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var audioPlayer: AVAudioPlayer!
    @Published var isPlaying: Bool = false
    
    var myAudioPlayer = AVAudioPlayer()
    
    func play() {
        myAudioPlayer.play()
        isPlaying = true
    }
    
    func pause() {
        myAudioPlayer.pause()
        isPlaying = false
    }
    
    func loadAudio() {
        let sound = Bundle.main.path(forResource: "Dun Ringill", ofType: "mp3")
        do {
            myAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        } catch {
            print("Couldn't load player!")
        }
        
        if myAudioPlayer.delegate == nil {
            myAudioPlayer.delegate = self
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish playing!")
        isPlaying = false
        
        if flag {
            // For now, loop endlessly
            loadAudio()
            play()
        }
    }
    
    func enableBluetoothOutput() {
        let session = AVAudioSession.sharedInstance()
        
        // This block disables Bluetooth playback
//        do {
//            try session.setCategory(.playback, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
//        } catch {
//            print("AVAudioSession error!")
//        }
        
        // This block enables Bluetooth playback
        do {
            try session.setCategory(.playback, options: AVAudioSession.CategoryOptions.allowBluetooth)
        } catch {
            print("AVAudioSession error!")
        }
    }
    
    var systemVolume: Float = 0.0
    
    func getSystemVolume() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    func setSystemVolumeToMax() {
        systemVolume = getSystemVolume()
        print("Saving volume of \(systemVolume)!")
        MPVolumeView.setVolume(1.0)
    }
    
    func returnSystemVolume() {
        print("Restoring volume to \(systemVolume)!")
        MPVolumeView.setVolume(systemVolume)
    }
}
