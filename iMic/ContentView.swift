//
//  ContentView.swift
//  iMic
//
//  Created by Alex Broadhead on 3/3/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State var audioHandler: AudioHandler = AudioHandler()
    @State var showPlay: Bool = true
    
    var body: some View {
        VStack {
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
            audioHandler.loadAudio()                // load and play our file
            audioHandler.enableBluetoothOutput()    // send output to Bluetooth, if available
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
}
