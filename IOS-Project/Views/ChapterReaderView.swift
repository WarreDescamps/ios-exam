//
//  ChapterReaderView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 12/12/2022.
//

import SwiftUI

struct ChapterReaderView: View {
    @StateObject var mangadex = SingletonManager.instance(key: "readerView")
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @State private var focusMode = true
    @State private var page = 1
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    @State private var reader: readerType = .manga
    @State var chapter: Chapter
    let manga: Manga
    
    var body: some View {
        ZStack {
            Color.black
            
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        screenWidth = geo.size.width
                        screenHeight = geo.size.height
                    }
            }
            
            switch reader {
            case .manga:
                VStack {
                    Spacer()
                    TabView(selection: $page) {
                        pages(links: mangadex.pages)
                            .rotationEffect(.degrees(-180))
                    }
                    .rotationEffect(.degrees(180))
                    .tabViewStyle(.page(indexDisplayMode: focusMode ? .never : .automatic))
                    Spacer()
                }
                HStack(spacing: 0) {
                    Button(action: nextPage) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.25)
                    }
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.5)
                    }
                    Button(action: prevPage) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.25)
                    }
                }
            case .webtoon:
                VStack {
                    Spacer()
                    TabView(selection: $page) {
                        pages(links: mangadex.pages)
                            .frame(width: screenWidth, height: screenHeight)
                            .rotationEffect(.degrees(-90))
                            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
                    }
                    .frame(width: screenWidth, height: screenHeight)
                    .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
                    .rotationEffect(.degrees(90))
                    .offset(x: screenWidth)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    Spacer()
                }
                VStack(spacing: 0) {
                    Button(action: prevPage) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.2)
                    }
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.6)
                    }
                    Button(action: nextPage) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.2)
                    }
                }
            }
        }
        .ignoresSafeArea(.all, edges: focusMode ? .vertical : .horizontal)
        .overlay(alignment: .topLeading) {
            if(!focusMode) {
                HStack {
                    Button(action: {
                        self.mode.wrappedValue.dismiss()
                    }) {
                        Label("Back", systemImage: "arrow.left")
                            .labelStyle(.iconOnly)
                    }
                    Spacer()
                    VStack {
                        if let title = chapter.title {
                            HStack {
                                Text(title)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                        HStack {
                            Text("Chapter \(chapter.number)")
                                .lineLimit(1)
                                .font(Font.headline.weight(.light))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 0)
                    Spacer()
                    Menu {
                        Button(action: { reader = .manga }) {
                            Text("Manga")
                        }
                        Button(action: { reader = .webtoon }) {
                            Text("Webtoon")
                        }
                    } label: {
                        Label("Reader Mode", systemImage: "book")
                            .labelStyle(.iconOnly)
                    }
                }
                .padding(.all)
                .background {
                    colorScheme == .dark ? Color.black : Color.white
                }
            }
        }
        .onAppear {
            SingletonManager.instance(key: "readerView").getPages(chapterId: chapter.id)
            HistoryManager.shared.getHistory(manga: manga)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func prevPage() {
        if page > 0 {
            page -= 1
        }
        if page == 0 {
            
        }
    }
    
    private func nextPage() {
        if page < mangadex.pages.count + 1 {
            page += 1
        }
        if page == mangadex.pages.count + 1 {
            let history = HistoryManager.shared.history
            if var history = history {
                updateHistory(history)
            }
            else {
                HistoryManager.shared.addHistory(manga: manga)
                if let history = HistoryManager.shared.history {
                    updateHistory(history)
                }
            }
        }
    }
    
    private func updateHistory(_ history: History) {
        var history = history
        if !history.chapters.contains(where: { $0 == chapter.number }) {
            history.chapters.append(chapter.number)
            HistoryManager.shared.history = history
            HistoryManager.shared.updateHistory(manga: manga)
        }
    }
    
    @ViewBuilder private func pages(links: [String]) -> some View {
        Text("First page")
            .foregroundColor(.white)
            .tag(0)
        ForEach(links.enumerated().reversed().reversed(), id: \.offset) { index, url in
            AsyncImage(url: URL(string: links.isEmpty ? "" : url),
                              content: { image in
                                   image
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .tag(index + 1)
                               },
                              placeholder: {
                       ZStack {
                           ProgressView()
                               .progressViewStyle(.circular)
                       }
            })
        }
        Text("Last page")
            .foregroundColor(.white)
            .tag(links.count + 1)
    }
    
    enum readerType {
        case webtoon
        case manga
    }
}

struct ChapterReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterReaderView_PreviewContainer()
    }
}


struct ChapterReaderView_PreviewContainer: View {
    var mangadex = SingletonManager.instance(key: "preview")
    
    init() {
        SingletonManager.instance(key: "preview").getChapters(mangaId: DebugConstants.worldTrigger.id)
    }
    
    var body: some View {
        ChapterReaderView(chapter: DebugConstants.currentChapter, manga: DebugConstants.worldTrigger)
    }
}
