//
//  ContentView.swift
//  iMic
//
//  Created by Alex Broadhead on 3/3/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer!
    @State var showPlay: Bool = true

    var body: some View {
        VStack {
            Text("iMic").font(.system(size: 45)).font(.largeTitle)
            
            HStack {
                if showPlay {
                    Button(action: {
                        play()
                    }) {
                        Image(systemName: "play.circle.fill").resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                    }
                }
                if !showPlay {
                    Button(action: {
                        pause()
                    }) {
                        Image(systemName: "pause.circle.fill").resizable()
                            .frame(width: 100, height: 100)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
        .onAppear {
            let sound = Bundle.main.path(forResource: "Dun Ringill", ofType: "mp3")
            self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
        }
    }
    
    func play() {
        self.audioPlayer.play()
        self.showPlay = false
    }
    
    func pause() {
        self.audioPlayer.pause()
        self.showPlay = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
