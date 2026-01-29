//
//  Recording.swift
//  VoiceRecorder
//
//  Created by hakisung on 1/28/26.
//

import Foundation

struct Recording: Identifiable {
    let id = UUID()
    let url: URL
    let createdAt: Date

    var displayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return "녹음 \(formatter.string(from: createdAt))"
    }

    var duration: String {
        // 파일 크기 기반 간이 표시
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = attributes?[.size] as? Int64 ?? 0
        let kb = Double(size) / 1024.0
        return String(format: "%.1f KB", kb)
    }
}

