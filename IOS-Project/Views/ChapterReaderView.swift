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
    @State private var isDismiss = false
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
                        screenHeight = geo.size.height - geo.safeAreaInsets.top
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
                VStack {
                    Spacer()
                    Text("\(min(mangadex.pages.count, max(0, page))) / \(mangadex.pages.count)")
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                }
            case .webtoon:
                ScrollView {
                    LazyVStack(spacing: 0) {
                        pages(links: mangadex.pages)
                    }
                }
                HStack {
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                    }
                }
//            case .manhwa:
//                VStack {
//                    Spacer()
//                    TabView(selection: $page) {
//                        pages(links: mangadex.pages)
//                            .frame(width: screenWidth, height: screenHeight)
//                            .rotationEffect(.degrees(-90))
//                            .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
//                    }
//                    .frame(width: screenWidth, height: screenHeight)
//                    .rotation3DEffect(.degrees(0), axis: (x: 1, y: 0, z: 0))
//                    .rotationEffect(.degrees(90))
//                    .offset(x: screenWidth)
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//                    Spacer()
//                }
//                VStack(spacing: 0) {
//                    Button(action: prevPage) {
//                        Rectangle()
//                            .foregroundColor(.clear)
//                            .frame(height: screenHeight * 0.2)
//                    }
//                    Button(action: {focusMode.toggle()}) {
//                        Rectangle()
//                            .foregroundColor(.clear)
//                            .frame(height: screenHeight * 0.6)
//                    }
//                    Button(action: nextPage) {
//                        Rectangle()
//                            .foregroundColor(.clear)
//                            .frame(height: screenHeight * 0.2)
//                    }
//                }
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
                                .if(chapter.title != nil) { view in
                                    view
                                        .font(.system(size: 14, weight: .light))
                                }
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
//                        Button(action: { reader = .manhwa }) {
//                            Text("Manhwa")
//                        }
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
            HistoryManager.shared.fetchFullHistory()
        }
        .onChange(of: page) { newValue in
            updateHistory()
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
        updateHistory()
    }
    
    private func updateHistory() {
        if page == mangadex.pages.count + 1 {
            if !(HistoryManager.shared.history?.chapters.contains(where: { $0 == chapter.number }) ?? false) {
                if HistoryManager.shared.history == nil {
                    HistoryManager.shared.history = History(mangaId: manga.id, lastRead: Date.now, chapters: [])
                }
                HistoryManager.shared.history?.chapters.append(chapter.number)
                HistoryManager.shared.updateHistory(manga: manga)
            }
        }
    }
    
    @ViewBuilder private func pages(links: [String]) -> some View {
        Text("First page")
            .foregroundColor(.white)
            .tag(0)
            .padding()
        ForEach(links.enumerated().map { Link(index: $0 + 1, url: $1) }) { link in
            AsyncImage(url: URL(string: links.isEmpty ? "" : link.url),
                              content: { image in
                                   image
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .tag(link.index)
                               },
                              placeholder: {
                       ZStack {
                           ProgressView()
                               .progressViewStyle(.circular)
                       }
            })
        }
        Text("End of Chapter \(chapter.number)")
            .font(.system(size: 25, weight: .bold))
            .foregroundColor(.white)
            .tag(links.count + 1)
            .padding(.all, 20)
    }
    
    struct Link: Identifiable, Hashable {
        var id: Int {
            index
        }
        
        var index: Int
        var url: String
    }
    
    enum readerType {
        case webtoon
        case manga
//        case manhwa
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
        _ = SingletonManager.userInstance(userId: DebugConstants.userId)
    }
    
    var body: some View {
        ChapterReaderView(chapter: DebugConstants.currentChapter, manga: DebugConstants.worldTrigger)
    }
}
