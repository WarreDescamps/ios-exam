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
                    isInLibrary.toggle()
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
                        Label("Collapse", systemImage: "chevron.up")
                            .labelStyle(.iconOnly)
                            .padding(.vertical, 1)
                        
                        WrappingHStack(manga.genres, id: \.self, spacing: .constant(20), lineSpacing: 10) {
                            Text($0)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(.gray)
                                        .scaleEffect(1.25)
                                }
                        }
                        .padding(.horizontal, 7)
                    }
                }
                .onTapGesture {
                    collapse.toggle()
                }
                
                HStack {
                    Text("\(mangadex.chapters.count) chapters")
                        .font(.system(size: 20))
                    Spacer()
                }
                LazyVStack {
                    ForEach(mangadex.chapters) { chapter in
                        HStack {
                            Text("Chapter \(chapter.number)\(chapter.title == nil ? "" : ": \(chapter.title!)")")
                                .lineLimit(1)
                            Spacer()
                        }
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
