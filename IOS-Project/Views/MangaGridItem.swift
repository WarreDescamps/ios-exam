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
    let parentTitle: String
    
    init(manga: Manga, showDetail: Binding<Bool>, parentTitle: String = "", isSelectable: Bool = false) {
        self.manga = manga
        self._showDetail = showDetail
        self.isSelectable = isSelectable
        self.parentTitle = parentTitle
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
                MangaDetailView(manga: manga, parentTitle: parentTitle, onDismiss: { showDetail = false })
            }
            .hidden()
        }
    }
}

struct SelectableMangaGridItem: View {
    var manga: Manga
    var parentTitle = ""
    @Binding var selectionState: ViewState
    @Binding var selectedManga: [Manga]
    @State var showDetail = false
    
    var body: some View {
        MangaGridItem(manga: manga, showDetail: $showDetail, parentTitle: parentTitle, isSelectable: true)
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
                    .onTapGesture(perform: changeSelection)
                    .onLongPressGesture(perform: changeSelection)
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
    
    private func changeSelection() {
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

struct MangaGridItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MangaGridItem_PreviewContainer()
            SelectableMangaGridItem_PreviewContainer()
        }
    }
}

struct MangaGridItem_PreviewContainer: View {
    @State private var showDetail = false
    var body: some View {
        MangaGridItem(manga: DebugConstants.worldTrigger, showDetail: $showDetail)
    }
}

struct SelectableMangaGridItem_PreviewContainer: View {
    @State private var selectionState: ViewState = .viewing
    @State private var selectedManga = [Manga]()
    var body: some View {
        SelectableMangaGridItem(manga: DebugConstants.worldTrigger, selectionState: $selectionState, selectedManga: $selectedManga)
    }
}
