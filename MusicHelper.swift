//
//  MusicHelper.swift
//  FlickrSearch
//
//  Created by Abhijith Sreekar on 8/2/16.
//  Copyright © 2016 Kyle Clegg. All rights reserved.
//

import AVFoundation

class MusicHelper {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        let aSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("coolsong", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL:aSound)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print("Cannot play the file")
        }
    }
}