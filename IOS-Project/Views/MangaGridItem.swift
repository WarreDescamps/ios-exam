//
//  MangaGridItem.swift
//  IOS-Project
//
//  Created by Warre Descamps on 07/12/2022.
//

import SwiftUI

struct MangaGridItem: View {
    var manga: Manga
    @Binding var showDetail: Bool
    let isSelectable: Bool
    
    init(manga: Manga) {
        self.manga = manga
        self.isSelectable = false
        var showDetail = false
        self._showDetail = Binding(get: { showDetail }, set: { showDetail = $0 })
    }
    
    init(manga: Manga, showDetail: Binding<Bool>) {
        self.manga = manga
        self.isSelectable = true
        self._showDetail = showDetail
    }
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: manga.coverUrl),
                       content: { image in image.resizable() },
                       placeholder: {
                ZStack {
                    Color.gray
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            })
            //.aspectRatio(contentMode: .fit)
            .aspectRatio(0.66, contentMode: .fit)
            .overlay(alignment: .bottom) {
                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .bottom, endPoint: .top)
                    .frame(height: 90.0)
            }
            .overlay(alignment: .bottomLeading) {
                Text(manga.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding([.leading, .bottom], 5.0)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .if(!isSelectable) { view in
                view
                    .onTapGesture {
                        showDetail = true
                    }
            }
            
            NavigationLink("Hidden", isActive: $showDetail) {
                MangaDetailView(manga: manga, onDismiss: { showDetail = false })
            }
            .hidden()
        }
    }
}

struct SelectableMangaGridItem: View {
    var manga: Manga
    @Binding var selectionState: ViewState
    @Binding var selectedManga: [Manga]
    @State var showDetail = false
    
    var body: some View {
        MangaGridItem(manga: manga, showDetail: $showDetail)
            .if(selectionState == .viewing) { view in
                view
                    .onTapGesture { showDetail = true }
                    .onLongPressGesture() {
                        DispatchQueue.main.async {
                            selectedManga.removeAll()
                            selectedManga.append(manga)
                            selectionState = .selecting
                        }
                    }
            }
            .if(selectionState == .selecting) { view in
                view
                    .onTapGesture {
                        DispatchQueue.main.async {
                            if selectedManga.contains(where: { $0.id == manga.id }) {
                                selectedManga.removeAll(where: { $0.id == manga.id })
                            }
                            else {
                                selectedManga.append(manga)
                            }
                        }
                    }
            }
            .if(selectionState == .selecting && selectedManga.contains(where: { $0.id == manga.id })) { view in
                view
                    .overlay(alignment: .center) {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.white)
                            .opacity(0.2)
                            .overlay(alignment: .center) {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(style: StrokeStyle(lineWidth: 5))
                                    .foregroundColor(.blue)
                            }
                    }
            }
    }
}

struct MangaGridItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MangaGridItem(manga: DebugConstants.worldTrigger)
            SelectableMangaGridItem_PreviewContainer()
        }
    }
}

struct SelectableMangaGridItem_PreviewContainer: View {
    @State private var selectionState: ViewState = .viewing
    @State private var selectedManga = [Manga]()
    var body: some View {
        SelectableMangaGridItem(manga: DebugConstants.worldTrigger, selectionState: $selectionState, selectedManga: $selectedManga)
    }
}
