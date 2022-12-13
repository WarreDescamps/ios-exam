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
    var chapter: Chapter
    
    init(chapter: Chapter){
        self.chapter = chapter
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
                    page(url: mangadex.pages.isEmpty ? "" : mangadex.pages[page])
                    Spacer()
                }
                HStack(spacing: 0) {
                    Button(action: {if page < mangadex.pages.count - 1 {
                        page += 1
                    }}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.25)
                    }
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.5)
                    }
                    Button(action: {if page > 0 {
                        page -= 1
                    }}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: screenWidth * 0.25)
                    }
                }
                .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            if horizontalAmount > 0 {
                                if page < mangadex.pages.count - 1 {
                                    page += 1
                                }
                            }
                            else {
                                if page > 0 {
                                    page -= 1
                                }
                            }
                        }
                    })
            }
            
            if reader == .webtoon {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(mangadex.pages, id: \.self) { url in
                            page(url: url)
                        }
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
                    page(url: mangadex.pages.isEmpty ? "" : mangadex.pages[page])
                    Spacer()
                }
                VStack(spacing: 0) {
                    Button(action: {if page > 0 {
                        page -= 1
                    }}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.2)
                    }
                    Button(action: {focusMode.toggle()}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.6)
                    }
                    Button(action: {if page < mangadex.pages.count - 1 {
                        page += 1
                    }}) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: screenHeight * 0.2)
                    }
                }
                .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        
                        if abs(horizontalAmount) < abs(verticalAmount) {
                            if verticalAmount < 0 {
                                if page < mangadex.pages.count - 1 {
                                    page += 1
                                }
                            }
                            else {
                                if page > 0 {
                                    page -= 1
                                }
                            }
                        }
                    })
            }
        }
        .ignoresSafeArea(.all, edges: focusMode ? .all : .horizontal)
        .onAppear {
            SingletonManager.instance(key: "readerView").getPages(chapterId: chapter.id)
        }
        .navigationTitle("Chapter \(chapter.number)\(chapter.title == nil ? "" : ": \(chapter.title!)")")
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
        }){
            Label("Back", systemImage: "arrow.left")
                .labelStyle(.iconOnly)
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(focusMode ? .hidden : .visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func page(url: String) -> some View {
        return AsyncImage(url: URL(string: url),
                            content: { image in image.resizable() },
                            placeholder: {
                     ZStack {
                         Color.gray
                         ProgressView()
                             .progressViewStyle(.circular)
                     }
                 })
        .aspectRatio(contentMode: .fit)
    }
    
    enum readerType {
        case webtoon
        case manga
        case manhwa
    }
}

struct ChapterReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterReaderView(chapter: DebugConstants.chapter)
    }
}
