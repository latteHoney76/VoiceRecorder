import SwiftUI

struct ContentView: View {
    @StateObject private var recorder = AudioRecorder()
    @StateObject private var player = AudioPlayer()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 녹음 파일 목록
                List {
                    if recorder.recordings.isEmpty {
                        Text("녹음 파일이 없습니다")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(recorder.recordings) { recording in
                            RecordingRow(
                                recording: recording,
                                isPlaying: player.currentURL == recording.url && player.isPlaying
                            )
                            .onTapGesture {
                                player.play(url: recording.url)
                            }
                        }
                        .onDelete(perform: recorder.deleteRecording)
                    }
                }
                .listStyle(.plain)

                Divider()

                // 녹음 버튼
                RecordButton(isRecording: recorder.isRecording) {
                    if recorder.isRecording {
                        recorder.stopRecording()
                    } else {
                        recorder.startRecording()
                    }
                }
                .padding(.vertical, 30)
            }
            .navigationTitle("녹음기")
            .toolbar {
                EditButton()
            }
        }
    }
}

// MARK: - 녹음 파일 행
struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool

    var body: some View {
        HStack {
            Image(systemName: isPlaying ? "speaker.wave.2.fill" : "waveform")
                .foregroundColor(isPlaying ? .blue : .gray)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(recording.displayName)
                    .font(.body)
                Text(recording.duration)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                .font(.title2)
                .foregroundColor(isPlaying ? .red : .blue)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 녹음 버튼
struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red.opacity(0.2) : Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)

                Circle()
                    .fill(isRecording ? Color.red : Color.red.opacity(0.8))
                    .frame(width: isRecording ? 35 : 60, height: isRecording ? 35 : 60)
                    .cornerRadius(isRecording ? 8 : 30)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
            }
        }

        Text(isRecording ? "녹음 중..." : "탭하여 녹음")
            .font(.caption)
            .foregroundColor(.gray)
    }
}

#Preview {
    ContentView()
}
