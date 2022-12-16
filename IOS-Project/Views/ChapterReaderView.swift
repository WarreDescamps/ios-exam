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
    @State private var page = 0
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    @State private var reader: readerType = .manga
    
    @State var previousChapter: Chapter?
    @State var currentChapter: Chapter
    @State var nextChapter: Chapter?
    var chapterCallback: (() -> [Chapter])? = nil
    
    init(previousChapter: Chapter?, currentChapter: Chapter, nextChapter: Chapter?, chapterCallback: @escaping () -> [Chapter]) {
        self.previousChapter = previousChapter
        self.currentChapter = currentChapter
        self.nextChapter = nextChapter
        self.chapterCallback = chapterCallback
    }
    
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
            
            if reader == .manga {
                VStack {
                    Spacer()
                    TabView(selection: $page) {
                        pages(links: mangadex.pages)
                    }
                    .tabViewStyle(PageTabViewStyle())
                    Spacer()
                }
                HStack(spacing: 0) {
                    Button(action: nextPage) {
                        Rectangle()
                            .foregroundColor(.orange)
                            .frame(width: screenWidth * 0.25)
                    }
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.5)
                    }
                    Button(action: prevPage) {
                        Rectangle()
                            .foregroundColor(.orange)
                            .frame(width: screenWidth * 0.25)
                    }
                }
            }
            
            if reader == .webtoon {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        pages(links: mangadex.pages)
                    }
                }
                Button(action: { focusMode.toggle() }) {
                    Rectangle()
                        .foregroundColor(.clear)
                }
            }
            
            if reader == .manhwa {
                VStack {
                    Spacer()
                    pages(links: mangadex.pages)
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
        .ignoresSafeArea(.all, edges: focusMode ? .all : .horizontal)
        .onAppear {
            SingletonManager.instance(key: "readerView").getPages(chapterId: currentChapter.id)
        }
        .navigationTitle("Chapter \(currentChapter.number)\(currentChapter.title == nil ? "" : ": \(currentChapter.title!)")")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { self.mode.wrappedValue.dismiss() }) {
                    Label("Back", systemImage: "arrow.left")
                        .labelStyle(.iconOnly)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { reader = .manga }) {
                        Text("Manga")
                    }
                    Button(action: { reader = .webtoon }) {
                        Text("Webtoon")
                    }
                    Button(action: { reader = .manhwa }) {
                        Text("Manhwa")
                    }
                } label: {
                    Label("Reader Mode", systemImage: "book")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(focusMode ? .hidden : .visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func prevPage() {
        if page < mangadex.pages.count - 1 {
            page += 1
        }
        else {
            toPrevChapter()
            SingletonManager.instance(key: "readerView").getPages(chapterId: currentChapter.id)
            page = mangadex.pages.count - 1
        }
    }
    
    func toPrevChapter() {
        if let previousChapter = self.previousChapter {
            self.nextChapter = self.currentChapter
            self.currentChapter = previousChapter
            if let chapterCallback = chapterCallback {
                let chapters = chapterCallback()
                let prevIndex = chapters.firstIndex(where: { chapter in chapter.id == self.currentChapter.id }) ?? 0 - 1
                self.previousChapter = prevIndex > 0 ? nil : chapters[prevIndex]
            }
        }
    }
    
    func nextPage() {
        if page > 0 {
            page -= 1
        }
        else {
            toNextChapter()
            page = 0
        }
    }
    
    func toNextChapter() {
        if let nextChapter = self.nextChapter {
            self.previousChapter = self.currentChapter
            self.currentChapter = nextChapter
            if let chapterCallback = chapterCallback {
                let chapters = chapterCallback()
                let nextIndex = chapters.firstIndex(where: { chapter in chapter.id == self.currentChapter.id }) ?? -2 + 1
                self.nextChapter = nextIndex == -1 ? nil : (nextIndex < chapters.count ? chapters[nextIndex] : nil)
            }
        }
    }
    
    func pages(links: [String]) -> some View {
        ForEach(links.enumerated().reversed().reversed(), id: \.offset) { index, url in
            AsyncImage(url: URL(string: links.isEmpty ? "" : url),
                              content: { image in
                                   image
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .tag(index)
                               },
                              placeholder: {
                       ZStack {
                           Color.gray
                           ProgressView()
                               .progressViewStyle(.circular)
                       }
            })
        }
    }
    
    enum readerType {
        case webtoon
        case manga
        case manhwa
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
        ChapterReaderView(previousChapter: DebugConstants.prevChapter, currentChapter: DebugConstants.currentChapter, nextChapter: DebugConstants.nextChapter, chapterCallback: { mangadex.chapters })
    }
}
