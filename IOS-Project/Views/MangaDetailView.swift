//
//  MangaDetailView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 09/12/2022.
//

import SwiftUI
import WrappingHStack

struct MangaDetailView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme
    @StateObject var mangadex = SingletonManager.instance(key: "detailView")
    var manga: Manga
    var parentTitle: String
    var onDismiss: () -> Void
    @State var isInLibrary: Bool = false
    @State private var collapse = true
    @State private var screenWidth: CGFloat = 0
    @State private var screenHeight: CGFloat = 0
    @State private var sortIncreasing = false
    
    init(manga: Manga, onDismiss: @escaping () -> Void, parentTitle: String = "") {
        self.manga = manga
        self.onDismiss = onDismiss
        self.parentTitle = parentTitle
    }
    
    var body: some View {
        ScrollView {
            VStack {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            screenWidth = geo.size.width
                            screenHeight = geo.size.height
                        }
                        .frame(height: 0)
                }
                HStack {
                        AsyncImage(url: URL(string: manga.coverUrl),
                                   content: { image in image.resizable() },
                                   placeholder: {
                            ZStack {
                                Color.gray
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                        })
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: screenWidth * 0.4, alignment: .leading)
                    
                    VStack(alignment: .leading) {
                        Text(manga.title)
                        ForEach(manga.authors, id: \.self) { author in
                            Text(author)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                
                Button {
                    if isInLibrary {
                        MangaManager.shared.deleteManga(mangaId: manga.id)
                    }
                    else {
                        MangaManager.shared.addManga(manga: manga)
                    }
                    withAnimation {
                        isInLibrary.toggle()
                    }
                } label: {
                    VStack {
                        Image(systemName: isInLibrary ? "heart.fill" : "heart")
                            .scaleEffect(1.25)
                            .padding(.bottom, 5)
                        Text(isInLibrary ? "In library" : "Add to Library")
                    }
                    .padding(.vertical)
                }
                
                VStack {
                    VStack {
                        Text(manga.description)
                            .if(collapse) { view in
                                view
                                    .lineLimit(3)
                                    .overlay(alignment: .bottom) {
                                        ZStack {
                                            LinearGradient(gradient: Gradient(colors: [colorScheme == .dark ? .black : .white, .clear]), startPoint: .bottom, endPoint: .top)
                                                .frame(height: 60.0)
                                                .overlay(alignment: .bottom) {
                                                    Label("Collapse", systemImage: "chevron.down")
                                                        .labelStyle(.iconOnly)
                                                }
                                        }
                                    }
                            }
                        if !collapse {
                            Label("Collapse", systemImage: "chevron.up")
                                .labelStyle(.iconOnly)
                                .padding(.vertical, 1)
                        }
                    }
                    .onTapGesture {
                        collapse.toggle()
                    }
                    
                    if collapse {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.flexible())], spacing: 20) {
                                ForEach(manga.genres, id: \.self) { genre in
                                    Text(genre)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .foregroundColor(.gray)
                                                .scaleEffect(1.25)
                                        }
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 7)
                        }
                    }
                    else {
                        WrappingHStack(manga.genres, id: \.self, spacing: .constant(20), lineSpacing: 10) {
                            Text($0)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(.gray)
                                        .scaleEffect(1.25)
                                }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 7)
                    }
                }
                
                HStack {
                    Text("\(mangadex.chapters.count) chapters")
                        .font(.system(size: 20))
                    Spacer()
                }
                LazyVStack {
                    ForEach(sortArray(array: mangadex.chapters, selector: { $0.number }, ascending: sortIncreasing)) { chapter in
                        NavigationLink {
                            ChapterReaderView(chapter: chapter)
                        } label: {
                            ChapterRow(chapter: chapter)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
        .onAppear {
            mangadex.getChapters(mangaId: manga.id)
            MangaManager.shared.getManga(completion: { self.isInLibrary = $0.contains(where: { $0 == manga.id }) })
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            onDismiss()
            self.mode.wrappedValue.dismiss()
        }){
            Label(parentTitle, systemImage: "chevron.backward")
                .labelStyle(.titleAndIcon)
        })
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { sortIncreasing.toggle() }) {
                    Label("Sort", systemImage: "line.horizontal.3.decrease")
                        .if(sortIncreasing) { view in
                            view.rotationEffect(.degrees(180))
                        }
                }
                .labelStyle(.iconOnly)
            }
        }
    }
    
    private func sortArray<T>(array: [T], selector: (T) -> String, ascending: Bool) -> [T] {
        let paddingLength = array.map({ selector($0) }).map({ $0.count }).max() ?? 0

        return array.sorted { (item1, item2) in
            let value1 = selector(item1).leftPadding(toLength: paddingLength, withPad: "0")
            let value2 = selector(item2).leftPadding(toLength: paddingLength, withPad: "0")

            if ascending {
                return value1 < value2
            } else {
                return value1 > value2
            }
        }
    }
}

struct MangaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MangaDetailView_PreviewContainer()
    }
}

struct MangaDetailView_PreviewContainer: View {
    @State var isShown: Bool = true
    
    var body: some View {
        MangaDetailView(manga: DebugConstants.worldTrigger, onDismiss: {isShown = false})
    }
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
