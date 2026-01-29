//
//  AudioPlayer.swift
//  VoiceRecorder
//
//  Created by hakisung on 1/28/26.
//

import AVFoundation
import Foundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentURL: URL?

    private var audioPlayer: AVAudioPlayer?

    func play(url: URL) {
        // 같은 파일을 다시 누르면 정지
        if currentURL == url && isPlaying {
            stop()
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            currentURL = url
        } catch {
            print("재생 실패: \(error.localizedDescription)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentURL = nil
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentURL = nil
    }
}
