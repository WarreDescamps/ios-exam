//
//  ChapterRow.swift
//  IOS-Project
//
//  Created by Warre Descamps on 12/12/2022.
//

import SwiftUI

struct ChapterRow: View {
    var chapter: Chapter
    
    var body: some View {
        VStack {
            HStack {
                Text("Chapter \(chapter.number)\(chapter.title == nil ? "" : ": \(chapter.title!)")")
                    .lineLimit(1)
                Spacer()
            }
            HStack {
                Text(relativeDate())
                    .lineLimit(1)
                    .font(.system(size: 16))
                    .foregroundColor(.init(white: 0.33))
                Spacer()
            }
        }
        .padding(.vertical, 5)
    }
    
    private func relativeDate() -> String {
        if Calendar(identifier: .iso8601).dateComponents([.month], from: chapter.updatedAt, to: Date.now).month ?? 0 < 2 {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: chapter.updatedAt, relativeTo: Date.now)
        }
        return chapter.updatedAt.formatted(date: .numeric, time: .omitted)
    }
}

struct ChapterRow_Previews: PreviewProvider {
    static var previews: some View {
        ChapterRow(chapter: DebugConstants.chapter)
    }
}
