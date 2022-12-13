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
    @State private var focusMode = true
    @State private var page = 0
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    var chapter: Chapter
    
    init(chapter: Chapter){
        self.chapter = chapter
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        screenWidth = geo.size.width
                        screenHeight = geo.size.height
                    }
                    .frame(height: 0)
            }
            Color.black
            VStack {
                Spacer()
                AsyncImage(url: URL(string: mangadex.pages.isEmpty ? "" : mangadex.pages[page]),
                                    content: { image in image.resizable() },
                                    placeholder: {
                             ZStack {
                                 Color.gray
                                 ProgressView()
                                     .progressViewStyle(.circular)
                             }
                         })
                .aspectRatio(contentMode: .fit)
                Spacer()
            }
            HStack(spacing: 0) {
                Button(action: {if page < mangadex.pages.count - 1 {
                    page += 1
                }}) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: screenWidth * 0.3)
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
                        .frame(width: screenWidth * 0.3)
                }
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
    
    
}

struct ChapterReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ChapterReaderView(chapter: DebugConstants.chapter)
    }
}
