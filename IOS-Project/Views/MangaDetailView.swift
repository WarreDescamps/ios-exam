//
//  MangaDetailView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 09/12/2022.
//

import SwiftUI

struct MangaDetailView: View {
    @State var manga: Manga
    var parentTitle = ""
    var onDismiss: () -> Void
    
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
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
                .aspectRatio(0.66, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(manga.title)
                    .frame(alignment: .leading)
            }
            Text(manga.description)
            Spacer()
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
