//
//  AudioRecorder.swift
//  VoiceRecorder
//
//  Created by hakisung on 1/28/26.
//

import AVFoundation
import Foundation

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordings: [Recording] = []

    private var audioRecorder: AVAudioRecorder?

    override init() {
        super.init()
        loadRecordings()
    }

    // MARK: - 녹음 시작
    func startRecording() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error.localizedDescription)")
            return
        }

        let fileName = "\(Date().timeIntervalSince1970).m4a"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 녹음 중지
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        loadRecordings()
    }

    // MARK: - 녹음 파일 목록 불러오기
    func loadRecordings() {
        let directory = getDocumentsDirectory()

        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )

            recordings = files
                .filter { $0.pathExtension == "m4a" }
                .compactMap { url in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let date = attributes?[.creationDate] as? Date ?? Date()
                    return Recording(url: url, createdAt: date)
                }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("파일 목록 불러오기 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 녹음 파일 삭제
    func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            try? FileManager.default.removeItem(at: recording.url)
        }
        recordings.remove(atOffsets: offsets)
    }

    // MARK: - Documents 디렉토리 경로
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
