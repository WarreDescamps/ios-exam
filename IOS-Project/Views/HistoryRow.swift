//
//  HistoryRow.swift
//  IOS-Project
//
//  Created by Warre Descamps on 20/12/2022.
//

import SwiftUI

struct HistoryRow: View {
    var manga: Manga
    var history: History
    @State private var screenWidth: CGFloat = 0
    @StateObject private var mangadex = SingletonManager.instance(key: "history")
    
    init(manga: Manga, history: History) {
        self.manga = manga
        self.history = history
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        screenWidth = geo.size.width
                    }
            }
            NavigationLink {
                if let chapter = mangadex.getChapter(mangaId: manga.id, chapterNumber: history.chapters.sorted().last ?? "1") {
                    ChapterReaderView(chapter: chapter, manga: manga)
                }
                else {
                    ZStack {
                        Color.black
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .padding()
                            Text("Something went wrong :(")
                                .font(.system(size: 30))
                        }
                    }
                }
            } label: {
                NavigationLink {
                    MangaDetailView(manga: manga)
                } label: {
                    AsyncImage(url: URL(string: manga.coverUrl),
                               content: { image in
                                    image
                                        .resizable()
                                },
                               placeholder: {
                                    ZStack {
                                        Color.gray
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    }
                                }
                    )
                    .aspectRatio(0.66, contentMode: .fit)
                    .frame(width: screenWidth * 0.12)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 10)
                VStack {
                    HStack {
                        Text(manga.title)
                            .font(Font.headline.weight(.semibold))
                        Spacer()
                    }
                    if let date = history.lastRead {
                        HStack {
                            Text("Ch. \(history.chapters.sorted().first ?? "")")
                            Text("-")
                            Text(date, style: .time)
                            Spacer()
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(manga: DebugConstants.worldTrigger, history: History(mangaId: DebugConstants.worldTrigger.id, lastRead: Date.now, chapters: ["1", "2", "3"]))
    }
}
